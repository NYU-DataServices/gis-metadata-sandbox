### ```gis-metadata``` Overview

This ```gis-metadata``` repository is the place where the NYU Libraries and Data Services team houses records that we have cleaned and enhanced but are not a part of the OpenGeoMetadata repository. They are indexed directly into the ```geo.nyu.edu``` production instance of the Spatial Data Repository, but they may be different from records that exist on ```OpenGeoMetadata```.

#### Management Workflow

Local records adhere to the top-level naming convetion of ```source-records```. Upon creation, push local records to this repository, provided that large collections are broken out into a pear tree structure, with individual files that are named ```geoblacklight.json```.

#### Ingest scripts

Note that this repository includes an ```index-local-collections.rb``` script that appends records with NYU-specific fields before indexing them into production. The script should be modified upon index to filter the appropriate records.
