## strelka-nf
### Strelka pipeline with Nextflow

#### Dependencies
1. Install [Strelka](https://sites.google.com/site/strelkasomaticvariantcaller/home/strelka-workflow-installation).
2. Install [nextflow](http://www.nextflow.io/).

	```bash
	curl -fsSL get.nextflow.io | bash
	```
	And move it to a location in your `$PATH` (`/usr/local/bin` for example here):
	```bash
	sudo mv nextflow /usr/local/bin
	```

#### Execution
Nextflow seamlessly integrates with GitHub hosted code repositories:

`nextflow run iarcbioinfo/strelka-nf --tn_file pairs.txt --bam_path bam_folder/ --ref ref.fasta --strelka path_to_strelka --config strelka_config.ini`

#### Help section
You can print the help manual by providing `--help` in the execution command line:
```bash
nextflow run iarcbioinfo/strelka-nf --help
```
This shows details about optional and mandatory parameters provided by the user.  

#### pairs.txt format
The pairs.txt file is where you can define pairs of bam to analyse with strelka. It's a tabular file with 2 columns normal and tumor.

| normal | tumor |
| ----------- | ---------- |
| normal1.bam | tumor2.bam |
| normal2.bam | tumor2.bam |
| normal3.bam | tumor3.bam |

#### Global parameters
```--strelka```, ```--config```, and ```--ref``` are mandatory parameters but can be defined in your nextflow config file (```~/.nextflow/config``` or ```config``` in the working directory) and so not set as inputs.

The following is an example of config part defining this:
```bash
profiles {

        standard {
                params {
                   ref = '~/Documents/Data/references/hg19.fasta'
                   strelka = '~/bin/strelka/1.0.15/bin/'
                   config = '~/bin/strelka/1.0.15/bin/strelka_config_bwa_default.ini'
                }
        }
```
