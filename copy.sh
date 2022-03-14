#!/bin/bash
# Copying a small slice of IHR database

STARTTIME='2022-03-10 00:00'
ENDTIME='2022-03-10 08:00'

IHR_HOST='eric.iijlab.net'
IHR_DB='ihr'
IHR_USER='romain'

COPY_HOST='localhost'
COPY_DB='ihr_dev'
COPY_USER='romain'

mkdir $STARTTIME

BACKUP_SCHEMA() {
    pg_dump -U romain -h $IHR_HOST --schema-only $IHR_DB | psql $COPY_DB
}


COPY_PARTIAL_TABLE() {
    # Copy to temp file
    psql -h $IHR_HOST -d $IHR_DB -U $IHR_USER -c "\\COPY (SELECT * FROM $1 WHERE timebin>='$STARTTIME' AND timebin<'$ENDTIME') TO '$STARTTIME/$1.csv' WITH (DELIMITER ',', FORMAT CSV)";

    # Import in new db
    psql -h $COPY_HOST -d $COPY_DB -U $COPY_USER -c "\\COPY $1 FROM '$STARTTIME/$1.csv' CSV"
}

#IMPORT_PARTIAL_TABLE() {
    #psql -h $COPY_HOST -d $COPY_DB -U $COPY_USER -c "\\COPY $1 FROM '$STARTTIME/$1.csv' CSV"
#}

COPY_FULL_TABLE() {
    pg_dump -U $IHR_USER -h $IHR_HOST -a -t $1 $IHR_DB | psql $COPY_DB 
}

BACKUP_SCHEMA
COPY_FULL_TABLE ihr_asn 
COPY_PARTIAL_TABLE ihr_atlas_delay
COPY_PARTIAL_TABLE ihr_atlas_delay_alarms
COPY_FULL_TABLE ihr_atlas_delay_alarms_id_seq
COPY_FULL_TABLE ihr_atlas_delay_id_seq
COPY_FULL_TABLE ihr_atlas_location 
COPY_FULL_TABLE ihr_atlas_location_id_seq
COPY_FULL_TABLE ihr_country
COPY_PARTIAL_TABLE ihr_delay
COPY_PARTIAL_TABLE ihr_delay_alarms
COPY_PARTIAL_TABLE ihr_delay_alarms_msms
COPY_PARTIAL_TABLE ihr_disco_events
COPY_FULL_TABLE ihr_disco_events_id_seq 
COPY_PARTIAL_TABLE ihr_disco_probes
COPY_FULL_TABLE ihr_disco_probes_id_seq
COPY_PARTIAL_TABLE ihr_forwarding
COPY_PARTIAL_TABLE ihr_forwarding_alarms
COPY_FULL_TABLE ihr_forwarding_alarms_id_seq
COPY_PARTIAL_TABLE ihr_forwarding_alarms_msms
COPY_FULL_TABLE ihr_forwarding_alarms_msms_id_seq
COPY_FULL_TABLE ihr_forwarding_id_seq
COPY_PARTIAL_TABLE ihr_hegemony
COPY_PARTIAL_TABLE ihr_hegemony_alarms
COPY_FULL_TABLE ihr_hegemony_alarms_id_seq
COPY_PARTIAL_TABLE ihr_hegemonycone
COPY_FULL_TABLE ihr_hegemonycone_id_seq
COPY_PARTIAL_TABLE ihr_hegemony_country
COPY_FULL_TABLE ihr_hegemony_country_id_seq
COPY_FULL_TABLE ihr_hegemony_id_seq
COPY_PARTIAL_TABLE ihr_hegemony_prefix
COPY_FULL_TABLE ihr_hegemony_prefix_id_seq
