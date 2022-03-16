#!/bin/bash
# Copying a small slice of IHR database

STARTTIME='2022-03-10'
ENDTIME='2022-03-10 08:00'

IHR_HOST='eric.iijlab.net'
IHR_DB='ihr'
IHR_USER='romain'

COPY_HOST='localhost'
COPY_DB='ihr_dev' # never put ihr here
COPY_USER='romain'

FINAL_OUTPUT='snapshot.dump'

mkdir $STARTTIME

CREATE_DB(){
    echo re-create $COPY_DB;
    dropdb $COPY_DB
    createdb -U $COPY_USER $COPY_DB
}

BACKUP_SCHEMA() {
    echo copy schema;
    # specify all tables to avoid timescale hypertables
    pg_dump -U $IHR_USER -h $IHR_HOST --schema-only --no-tablespaces -t ihr_asn -t ihr_atlas_delay -t ihr_atlas_delay_alarms -t ihr_atlas_delay_alarms_id_seq -t ihr_atlas_delay_id_seq -t ihr_atlas_location -t ihr_atlas_location_id_seq -t ihr_country -t ihr_delay -t ihr_delay_alarms -t ihr_delay_alarms_msms -t ihr_disco_events -t ihr_disco_events_id_seq -t ihr_disco_probes -t ihr_disco_probes_id_seq -t ihr_forwarding -t ihr_forwarding_alarms -t ihr_forwarding_alarms_id_seq -t ihr_forwarding_alarms_msms -t ihr_forwarding_alarms_msms_id_seq -t ihr_forwarding_id_seq -t ihr_hegemony -t ihr_hegemony_alarms -t ihr_hegemony_alarms_id_seq -t ihr_hegemonycone -t ihr_hegemonycone_id_seq -t ihr_hegemony_country -t ihr_hegemony_country_id_seq -t ihr_hegemony_id_seq -t ihr_hegemony_prefix -t ihr_hegemony_prefix_id_seq  $IHR_DB | psql $COPY_DB
}


COPY_PARTIAL_TABLE() {
    echo partial copy of $1;
    # Copy to temp file
    psql -h $IHR_HOST -d $IHR_DB -U $IHR_USER -c "\\COPY (SELECT * FROM $1 WHERE timebin>='$STARTTIME' AND timebin<'$ENDTIME') TO '$STARTTIME/$1.csv' WITH (DELIMITER ',', FORMAT CSV)";

    # Import in new db
    psql -h $COPY_HOST -d $COPY_DB -U $COPY_USER -c "\\COPY $1 FROM '$STARTTIME/$1.csv' CSV"

    # Remove temp file
    rm $STARTTIME/$1.csv
}

#IMPORT_PARTIAL_TABLE() {
    #psql -h $COPY_HOST -d $COPY_DB -U $COPY_USER -c "\\COPY $1 FROM '$STARTTIME/$1.csv' CSV"
#}

COPY_FULL_TABLE() {
    echo full copy of $1;
    pg_dump -U $IHR_USER -h $IHR_HOST -a -t $1 $IHR_DB | psql $COPY_DB 
}

DUMP_SNAPSHOT() {
    echo dump data to $STARTTIME/$FINAL_OUTPUT;
    pg_dump -U $COPY_USER -h $COPY_HOST --data-only $COPY_DB > $STARTTIME/$FINAL_OUTPUT;
}

CREATE_DB

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
COPY_FULL_TABLE ihr_disco_probes_id_seq:
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

DUMP_SNAPSHOT
