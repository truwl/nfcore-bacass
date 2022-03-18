version 1.0

workflow bacass {
	input{
		File samplesheet
		String outdir = "./results"
		String? email
		String? kraken2db
		String assembler = "unicycler"
		String assembly_type = "short"
		String? unicycler_args
		String? canu_args
		String polish_method = "medaka"
		String annotation_tool = "prokka"
		String? prokka_args
		String dfast_config = "assets/test_config_dfast.py"
		Boolean? skip_kraken2
		Boolean? skip_annotation
		Boolean? skip_pycoqc
		Boolean? skip_polish
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String publish_dir_mode = "copy"
		String? multiqc_title
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda
		Boolean? singularity_pull_docker_container

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			outdir = outdir,
			email = email,
			kraken2db = kraken2db,
			assembler = assembler,
			assembly_type = assembly_type,
			unicycler_args = unicycler_args,
			canu_args = canu_args,
			polish_method = polish_method,
			annotation_tool = annotation_tool,
			prokka_args = prokka_args,
			dfast_config = dfast_config,
			skip_kraken2 = skip_kraken2,
			skip_annotation = skip_annotation,
			skip_pycoqc = skip_pycoqc,
			skip_polish = skip_polish,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			help = help,
			publish_dir_mode = publish_dir_mode,
			multiqc_title = multiqc_title,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			validate_params = validate_params,
			show_hidden_params = show_hidden_params,
			enable_conda = enable_conda,
			singularity_pull_docker_container = singularity_pull_docker_container,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-bacass/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		String outdir = "./results"
		String? email
		String? kraken2db
		String assembler = "unicycler"
		String assembly_type = "short"
		String? unicycler_args
		String? canu_args
		String polish_method = "medaka"
		String annotation_tool = "prokka"
		String? prokka_args
		String dfast_config = "assets/test_config_dfast.py"
		Boolean? skip_kraken2
		Boolean? skip_annotation
		Boolean? skip_pycoqc
		Boolean? skip_polish
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String publish_dir_mode = "copy"
		String? multiqc_title
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda
		Boolean? singularity_pull_docker_container

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /bacass-2.0.0  -profile truwl,nfcore-bacass  --input ~{samplesheet} 	~{"--samplesheet '" + samplesheet + "'"}	~{"--outdir '" + outdir + "'"}	~{"--email '" + email + "'"}	~{"--kraken2db '" + kraken2db + "'"}	~{"--assembler '" + assembler + "'"}	~{"--assembly_type '" + assembly_type + "'"}	~{"--unicycler_args '" + unicycler_args + "'"}	~{"--canu_args '" + canu_args + "'"}	~{"--polish_method '" + polish_method + "'"}	~{"--annotation_tool '" + annotation_tool + "'"}	~{"--prokka_args '" + prokka_args + "'"}	~{"--dfast_config '" + dfast_config + "'"}	~{true="--skip_kraken2  " false="" skip_kraken2}	~{true="--skip_annotation  " false="" skip_annotation}	~{true="--skip_pycoqc  " false="" skip_pycoqc}	~{true="--skip_polish  " false="" skip_polish}	~{"--custom_config_version '" + custom_config_version + "'"}	~{"--custom_config_base '" + custom_config_base + "'"}	~{"--hostnames '" + hostnames + "'"}	~{"--config_profile_name '" + config_profile_name + "'"}	~{"--config_profile_description '" + config_profile_description + "'"}	~{"--config_profile_contact '" + config_profile_contact + "'"}	~{"--config_profile_url '" + config_profile_url + "'"}	~{"--max_cpus " + max_cpus}	~{"--max_memory '" + max_memory + "'"}	~{"--max_time '" + max_time + "'"}	~{true="--help  " false="" help}	~{"--publish_dir_mode '" + publish_dir_mode + "'"}	~{"--multiqc_title '" + multiqc_title + "'"}	~{"--email_on_fail '" + email_on_fail + "'"}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size '" + max_multiqc_email_size + "'"}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config '" + multiqc_config + "'"}	~{"--tracedir '" + tracedir + "'"}	~{true="--validate_params  " false="" validate_params}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{true="--enable_conda  " false="" enable_conda}	~{true="--singularity_pull_docker_container  " false="" singularity_pull_docker_container}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-bacass:2.0.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    