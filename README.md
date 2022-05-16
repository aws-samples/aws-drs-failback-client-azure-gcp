## What?

This package includes a shell script to convert the AWS Elastic Disaster Recovery (AWS DRS) provided failback client to a bootable disk that can be attached to a Compute Engine (VM) on Google Cloud Platform (GCP). This VM can later be used to initiate the failback process from GCP to AWS as part of a Disaster Recovery exercise. 


## Description

When testing or performing a disaster recovery solution, it’s often required not only to test the failover process (from primary to DR), but also to spin up the DR site, perform some writes there, and then failback from DR to primary to simulate a full cycle of an outage. This process is called a failback and during which the data replication direction has to be reversed. AWS DRS provides a Failback Client that help with this process. However, when your primary site is cloud, GCP or Azure for example, you can’t directly use that client because you can’t control the booting sequence on a VM on cloud. The only way to do so is by converting the failback Client to a bootable disk that is compatible with the cloud provider that hosts your primary workload. 

This package includes:
* The script that does that convert AWS DRS Failback Client livecd to a bootable disk on GCP <Convertor-GCP.sh>


## Conversion workflow



<img aligh="center" src="https://github.com/aws-samples/aws-drs-failback-client-gcp/blob/main/Conversion-workflow.png" width=750 height=450>



## Step by Step 

Add step by step instruction on how to run the script, inputs, parameters..etc and what is the expected output.


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

