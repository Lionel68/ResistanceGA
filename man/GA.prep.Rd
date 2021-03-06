% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GA_prep.R
\name{GA.prep}
\alias{GA.prep}
\title{Create R object with genetic algorithm optimization settings}
\usage{
GA.prep(ASCII.dir,
Results.dir=NULL,
min.cat=1e-04,
max.cat=2500,
max.cont=2500,
min.scale = NULL,
max.scale = NULL,
cont.shape=NULL,
select.trans=NULL,
method = "LL",
scale = FALSE,
scale.surfaces = NULL,
k.value = 3,
pop.mult = 15,
percent.elite = 0.05,
type= "real-valued",
pcrossover=0.85,
pmutation=0.125,
maxiter=1000,
run=25,
keepBest=TRUE,
population = gaControl(type)$population,
selection = gaControl(type)$selection,
crossover="gareal_blxCrossover",
mutation = gaControl(type)$mutation,
pop.size = NULL,
parallel = FALSE,
seed = NULL,
quiet = FALSE)
}
\arguments{
\item{ASCII.dir}{Directory containing all raster objects to optimized. If optimizing using least cost paths, a RasterStack or RasterLayer object can be specified.}

\item{Results.dir}{If a RasterStack is provided in place of a directory containing .asc files for ASCII.dir, then a directory to export optimization results must be specified. It is critical that there are NO SPACES in the directory, as this will cause the function to fail.}

\item{min.cat}{The minimum value to be assessed during optimization of of categorical resistance surfaces (Default = 1e-04)}

\item{max.cat}{The maximum value to be assessed during optimization of of categorical resistance surfaces (Default = 2500)}

\item{max.cont}{The maximum value to be assessed during optimization of of continuous resistance surfaces (Default = 2500)}

\item{min.scale}{The minimum scaling parameter value to be assessed during optimization of resistance surfaces with kernel smoothing (Default = 1)}

\item{max.scale}{The maximum scaling parameter value to be assessed during optimization of resistance surfaces with kernel smoothing (Default = 0.5 * nrows in the raster surface)}

\item{cont.shape}{A vector of hypothesized relationships that each continuous resistance surface will have in relation to the genetic distance reposnse (Default = NULL; see details)}

\item{select.trans}{Option to specify which transformations are applied to continuous surfaces. Must be provided as a list. "A" = All, "M" = Monomolecular only, "R" = Ricker only. See Details.}

\item{method}{Objective function to be optimized. Select "AIC", "R2", or "LL" to optimize resistance surfaces based on AIC, variance explained (R2), or log-likelihood. (Default = "LL")}

\item{scale}{Logical. To optimize a kernel smoothing scaling parameter during optimization, set to TRUE (Default = FALSE). See Details below.}

\item{scale.surfaces}{(Optional) If doing multisurface optimization with kernel smoothing, indicate which surfaces should be smoothed. A vector equal in length to the number of resistance surfaces to be optimized using MS_optim.scale that is used to indicate whether a surface should (1) or should not (0) have kernel smoothing applied. See details.}

\item{k.value}{Specification of how k, the number of parameters in the mixed effects model, is determined. Specify 1, 2, or 3 (Default = 3; see details).

1 --> k = 2;

2 --> k = number of parameters optimized plus the intercept;

3 --> k =  the number of parameters optimized plus the intercept and the number of layers optimized.}

\item{pop.mult}{Value will be multiplied with number of parameters in surface to determine 'popSize' in GA. By default this is set to 15.}

\item{percent.elite}{Percent used to determine the number of best fitness individuals to survive at each generation ('elitism' in GA). By default the top 5\% individuals will survive at each iteration.}

\item{type}{Default is "real-valued"}

\item{pcrossover}{Probability of crossover. Default = 0.85}

\item{pmutation}{Probability of mutation. Default = 0.125}

\item{maxiter}{Maximum number of iterations to run before the GA search is halted (Default = 1000)}

\item{run}{Number of consecutive generations without any improvement in AICc before the GA is stopped (Default = 25)}

\item{keepBest}{A logical argument specifying if best solutions at each iteration should be saved (Default = TRUE)}

\item{population}{Default is "gareal_Population" from GA}

\item{selection}{Default is "gareal_lsSelection" from GA}

\item{crossover}{Default = "gareal_blxCrossover". This crossover method greatly improved optimization during preliminary testing}

\item{mutation}{Default is "gareal_raMutation" from GA}

\item{pop.size}{Number of individuals to create each generation}

\item{parallel}{A logical argument specifying if parallel computing should be used (TRUE) or not (FALSE, default) for evaluating the fitness function. You can also specifiy the number of cores to use. Parallel processing currently only works when optimizing using least cost paths. It will fail if used with CIRCUITSCAPE, so this is currently not an option.}

\item{seed}{Integer random number seed to replicate \code{ga} optimization}

\item{quiet}{Logical. If TRUE, AICc and step run time will not be printed to the screen after each step. Only \code{ga} summary information will be printed following each iteration. Default = FALSE}
}
\value{
An R object that is a required input into optimization functions
}
\description{
This function prepares and compiles objects and commands for optimization with the GA package
}
\details{
Only files that you wish to optimize, either in isolation or simultaneously, should be included in the specified \code{ASCII.dir}. If you wish to optimize different combinations of surfaces, different directories contaiing these surfaces must be created.

When `scale = TRUE`, the standard deviation of the Gaussian kernel smoothing function (sigma) will also be optimized during optimization. Only continuous surfaces or binary categorical surfaces (e.g., forest/no forest; 1/0) surfaces can be optimized when `scale = TRUE`

\code{scale.surfaces} can be used to specify which surfaces to apply kernel smoothing to during multisurface optimization. \code{scale.surfaces = c(1, 0, 1)} will result in the first and third surfaces being optimized with a kernel smoothing function, while the second surface will not be scaled.

The Default for \code{k.value} is 3, which sets k equal to the number of parameters optimized plus the number of surfaces optimized, plus 1 for the intercept term. Prior to version 3.0-0, \code{k.value} could not be specified by the user and followed setting 2, such that k was equal to the number of parameters optimized plus the intercept term.

\code{cont.shape} can take values of "Increase", "Decrease", or "Peaked". If you believe a resistance surface is related to your response in a particular way, specifying this here may decrease the time to optimization. \code{cont.shape} is used to generate an initial set of parameter values to test during optimization. If specified, a greater proportion of the starting values will include your believed relatiosnship. If unspecified (the Default), a completely random set of starting values will be generated.

If it is desired that only certain transformations be assessed for continuous surfaces, then this can be specified using \code{select.trans}. By default, all transformations will be assessed for cntinuous surfaces unless otherwise specified. Specific transformations can be specified by providing a vector of values (e.g., \code{c(1,3,5)}), with values corresponding to the equation numbers as detailed in \code{\link[ResistanceGA]{Resistance.tran}}. If multiple rasters are to be optimized from the same directory, then a list of transformations must be provided in the order that the raster surfaces will be assessed. For example:\cr
\code{select.trans = list("M", "A", "R", c(5,6))}\cr
will result in surface one only being optimized with Monomolecular transformations, surface two with all transformations, surface three with only Ricker transformations, and surface four with Reverse Ricker and Reverse Monomolecular only. If a categorical surface is among the rasters to be optimized, it is necessary to specify \code{NA} to accomodate this.

It is recommended to first run GA optimization with the default settings
}
\author{
Bill Peterman <Bill.Peterman@gmail.com>
}
