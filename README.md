# singleStepPipeline

This repository holds a Snakemake based pipeline for using Stephan Preibisch's plugin (https://github.com/bigdataviewer/SPIM_Registration).

The beanshell directory holds a collection of beanshell scripts, which are calling the plugin headless.

The submitScripts folder contains LSF cluster submit scripts, using the beanshell scripts/

In snakefiles there are two Snakemake workflows, dealing with single and double sides illumination.

Most of these scripts are specifically tailored four our needs, but there is some generalisation built in, e.g. multiple channels are supported.
