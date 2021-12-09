## This script can be used to index records harvested from other institutions but motified locally into our production SDR.
## The script is written to index records one source at a time, but it can be modified to index according to a filter.

require 'rsolr'
require 'uri'
require 'find'
require 'json'
​
# irb_context.echo = false
​
PROD_MD_DIR = '/metadata/production/path/to/documents'
PROD_SOLR_URL = 'http://54.174.220.44:8983/solr/blacklight_core'
​
def add_nyu_fields(record)
  if record['nyu_addl_format_sm'].nil?
    mod = record.dup
    mod['nyu_addl_format_sm'] = [ mod['dc_format_s'] ]
    return mod
  else
    return record
  end
end
​
def filter(record)
  return true if ((record['dct_provenance_s'] == 'Institution') || (record['dc_rights_s'] == 'Public'))
  return false
end
​
## Find all `geoblacklight.json` records
files = Find.find(PROD_MD_DIR).select { |x| File.basename(x).include? ".json" }
records = files.map { |f| JSON.parse(File.read(f)) }
​
puts "Found #{records.count} possible json records in: #{PROD_MD_DIR}"
​
filtered_records = records.select { |r| filter(r) }
filtered_records.map! { |r| add_nyu_fields(r) }
​
puts "Found #{filtered_records.count} usable records in: #{PROD_MD_DIR}"
​
## Create a connection object
solr = RSolr.connect :url => PROD_SOLR_URL
​
## this Solr URL points to the local instance of Solr
​
## Optionally, confirm that you are connected
#results = solr.get 'select', :params => {:q => '*:*'}
​
completed_counter = 0
​
filtered_records.each_slice(100) do |slice|
  begin
    retries ||= 0
    solr.add slice
    solr.commit
    completed_counter += slice.length
    puts "[ #{completed_counter.to_f / filtered_records.count} ] #{completed_counter}/#{filtered_records.count} records have been indexed..."
  rescue
    puts "#### Failure! Check logs! ####"
    retry if (retries += 1) < 2
  end
end
