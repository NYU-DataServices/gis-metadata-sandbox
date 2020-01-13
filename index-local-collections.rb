## This script can be used to index records harvested from other institutions but motified locally into our production SDR.
## The script is written to index records one source at a time, but it can be modified to index according to a filter.

require 'rsolr'
require 'uri'
require 'find'
require 'json'

irb_context.echo = false

## Define the path where local records are

PROD_MD_DIR = '/home/ubuntu/metadata/production/local-collections/'
PROD_SOLR_URL = 'http://54.174.220.44:8983/solr/blacklight_core'

def add_nyu_fields(record)
  if record['nyu_addl_format_sm'].nil?
    mod = record.dup
    mod['nyu_addl_format_sm'] = [ mod['dc_format_s'] ]
    return mod
  else
    return record
  end
end

def filter(record)
  return true if ((record['dct_provenance_s'] == 'Columbia') || (record['dc_rights_s'] == 'Public'))
  return false
end


## Find all `geoblacklight.json` records
gbl = Find.find(PROD_MD_DIR).select{ |x| File.basename(x) == 'geoblacklight.json' || File.basename(x) == 'collection.json'}

puts "Found #{gbl.count} record files in: #{PROD_MD_DIR}"

filtered_records = [] ## A place to store them

gbl.each do |path|
  if File.basename(path) == "geoblacklight.json"
    record = JSON.parse(File.read(path)) ## Read and parse the record
    if (filter(record)) ## See if we want it; you can change the variables depending on how you want to filter
      filtered_records << add_nyu_fields(record)
    end
  elsif File.basename(path) == "collection.json"
    records = JSON.parse(File.read(path)) ## Read and parse the record
    filtered_records.concat records.select{ |x| filter(x) }.map{ |x| add_nyu_fields(x) }
  end
end

puts "Found #{filtered_records.count} usable records."

## Create a connection object
solr = RSolr.connect :url => PROD_SOLR_URL

## this Solr URL points to the local instance of Solr

## Optionally, confirm that you are connected
#results = solr.get 'select', :params => {:q => '*:*'}

completed_counter = 0

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
