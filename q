Changes in module 'nf-core/salmon/quant' between (94b06f1683ddf893cf06525f6e7f0573ad8fbf83) and (5d2c0dd6a8e2790e7ff511f7f4d761f4ed627a91)
--- a/modules/nf-core/salmon/quant/meta.yml
+++ b/modules/nf-core/salmon/quant/meta.yml
@@ -34,12 +34,12 @@
       type: file
       description: Fasta file of the reference transcriptome
   - alignment_mode:
-    type: boolean
-    description: whether to run salmon in alignment mode
+      type: boolean
+      description: whether to run salmon in alignment mode
   - lib_type:
-    type: string
-    description: |
-      Override library type inferred based on strandedness defined in meta object
+      type: string
+      description: |
+        Override library type inferred based on strandedness defined in meta object
 
 output:
   - results:

--- a/modules/nf-core/salmon/quant/main.nf
+++ b/modules/nf-core/salmon/quant/main.nf
@@ -2,10 +2,10 @@
     tag "$meta.id"
     label "process_medium"
 
-    conda "bioconda::salmon=1.9.0"
+    conda "bioconda::salmon=1.10.1"
     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
-        'https://depot.galaxyproject.org/singularity/salmon:1.9.0--h7e5ed60_1' :
-        'quay.io/biocontainers/salmon:1.9.0--h7e5ed60_1' }"
+        'https://depot.galaxyproject.org/singularity/salmon:1.10.1--h7e5ed60_0' :
+        'quay.io/biocontainers/salmon:1.10.1--h7e5ed60_0' }"
 
     input:
     tuple val(meta), path(reads)

************************************************************
Changes in './modules.json'
--- a/modules.json
+++ b/modules.json
@@ -28,7 +28,7 @@
                     },
                     "salmon/quant": {
                         "branch": "master",
-                        "git_sha": "94b06f1683ddf893cf06525f6e7f0573ad8fbf83",
+                        "git_sha": "5d2c0dd6a8e2790e7ff511f7f4d761f4ed627a91",
                         "installed_by": [
                             "modules"
                         ]
************************************************************
