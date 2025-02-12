# ! Note: this was written on 2025/01/03

I am writing this because my previous setup *stopped working* thanks to Google changing things.
Who knows if this will work when you want it too.

# Running the pipeline
To run the pipleline on Google Cloud, use [Google Batch](https://cloud.google.com/batch/docs/get-started)

If it is not already setup, this will require you to create a [Service Account](https://cloud.google.com/iam/docs/service-account-overview)
with the correct permissions.  Good luck finding those permissions! Just kidding, they are listed below.

## First, set the project

```
gcloud config set project ${PROJECT_ID}
```

## Enable APIs

```
gcloud services enable \
    batch.googleapis.com \
    compute.googleapis.com \
    logging.googleapis.com \
    storage.googleapis.com
```


## Create the service account

I am going to call the account `nf-runner`, but there is not a name requirement.

```
gcloud iam service-accounts create nf-runner \
  --description="run nextflow" \
  --display-name="nf-runner"
```

## Assign the required permissions to the service account

```
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:nf-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:nf-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/batch.agentReporter"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:nf-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/roles/storage.admin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:nf-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"
```

## Give yourself permission to use the service account

You likely already have these permissions, but in case...

```
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${YOUR_EMAIL_ADDRESS}" \
    --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${YOUR_EMAIL_ADDRESS}" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${YOUR_EMAIL_ADDRESS}" \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:${YOUR_EMAIL_ADDRESS}" \
    --role="roles/storage.objectAdmin"
```


## What *They* won't tell you

The above is the advice given by Google and Nextflow. There are, however, **additional**
permissions that are required or the pipeline will silently fail.

First, make the new service account able to call on the *existing* **compute service account**:

```
gcloud iam service-accounts add-iam-policy-binding \
  nf-runner@${PROJECT_ID}.iam.gserviceaccount.com \
  --member="user:${YOUR_EMAIL_ADDRESS}" \
  --role="roles/iam.serviceAccountUser"
```

Then, you need to enable the compute service to write batch results. If you do not, you will find that the logs 
(which can be found [here](https://console.cloud.google.com/batch/jobs), if you click on a job name, then the "LOGS" 
tab) of the instances created to run jobs will report that they do not have "batch.states.report" permission and they 
will just hang in a "Suspended" state.

```
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${COMPUTE_SERVICE_ACCOUNT}@developer.gserviceaccount.com" \
  --role="roles/batch.agentReporter"
```

## Copy the credentials to run the agent locally

On the [Service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) page, 
*click on the three 
vertical dots for the `nf-runner` account

Select:
* `keys`
* `ADD KEY`
* `Create new key`
* `JSON`
* save to a location accessible to Nextflow.

Export the location of that file as an environmental variable:
```
export GOOGLE_APPLICATION_CREDENTIALS="/home/milo/gcp_nextflow_authorization_key.json"
```


## Finally, run the pipeline:
```
nextflow run main.nf \
    -profile google_batch \
    -config rnaseq.config \
    -resume \
    --reads_pattern "*_S*_R{1,2}_00*.fastq.gz" \
    --project gs://${BUCKET}/${PROJECT} \
    --raw_fastqs gs://${BUCKET}/${PROJECT}/data/raw/ \
    --refs gs://${BUCKET}/references/ \
    --species ${SPECIES} \
    --pseudoalign \
    --results gs://${BUCKET}/${PROJECT}/results \
    --project_id ${PROJECT_ID} \
    --workdir_bucket "gs://${BUCKET}/scratch" \
    --scratch "gs://${BUCKET}/scratch"
```