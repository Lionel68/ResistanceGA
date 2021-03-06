#' Create R object with genetic algorithm optimization settings
#'
#' This function prepares and compiles objects and commands for optimization with the GA package
#'
#' @param ASCII.dir Directory containing all raster objects to optimized. If optimizing using least cost paths, a RasterStack or RasterLayer object can be specified.
#' @param Results.dir If a RasterStack is provided in place of a directory containing .asc files for ASCII.dir, then a directory to export optimization results must be specified. It is critical that there are NO SPACES in the directory, as this will cause the function to fail.
#' @param min.cat The minimum value to be assessed during optimization of of categorical resistance surfaces (Default = 1e-04)
#' @param max.cat The maximum value to be assessed during optimization of of categorical resistance surfaces (Default = 2500)
#' @param max.cont The maximum value to be assessed during optimization of of continuous resistance surfaces (Default = 2500)
#' @param min.scale The minimum scaling parameter value to be assessed during optimization of resistance surfaces with kernel smoothing (Default = 1)
#' @param max.scale The maximum scaling parameter value to be assessed during optimization of resistance surfaces with kernel smoothing (Default = 0.5 * nrows in the raster surface)
#' @param cont.shape A vector of hypothesized relationships that each continuous resistance surface will have in relation to the genetic distance reposnse (Default = NULL; see details)
#' @param select.trans Option to specify which transformations are applied to continuous surfaces. Must be provided as a list. "A" = All, "M" = Monomolecular only, "R" = Ricker only. See Details.
#' @param method Objective function to be optimized. Select "AIC", "R2", or "LL" to optimize resistance surfaces based on AIC, variance explained (R2), or log-likelihood. (Default = "LL")
#' @param scale Logical. To optimize a kernel smoothing scaling parameter during optimization, set to TRUE (Default = FALSE). See Details below.
#' @param scale.surfaces (Optional) If doing multisurface optimization with kernel smoothing, indicate which surfaces should be smoothed. A vector equal in length to the number of resistance surfaces to be optimized using MS_optim.scale that is used to indicate whether a surface should (1) or should not (0) have kernel smoothing applied. See details.
#' @param k.value Specification of how k, the number of parameters in the mixed effects model, is determined. Specify 1, 2, or 3 (Default = 3; see details).
#'
#' 1 --> k = 2;
#'
#' 2 --> k = number of parameters optimized plus the intercept;
#'
#' 3 --> k =  the number of parameters optimized plus the intercept and the number of layers optimized.
#' @param pop.mult Value will be multiplied with number of parameters in surface to determine 'popSize' in GA. By default this is set to 15.
#' @param percent.elite Percent used to determine the number of best fitness individuals to survive at each generation ('elitism' in GA). By default the top 5\% individuals will survive at each iteration.
#' @param type Default is "real-valued"
#' @param population Default is "gareal_Population" from GA
#' @param selection Default is "gareal_lsSelection" from GA
#' @param mutation Default is "gareal_raMutation" from GA
#' @param pcrossover Probability of crossover. Default = 0.85
#' @param pmutation Probability of mutation. Default = 0.125
#' @param crossover Default = "gareal_blxCrossover". This crossover method greatly improved optimization during preliminary testing
#' @param maxiter Maximum number of iterations to run before the GA search is halted (Default = 1000)
#' @param pop.size Number of individuals to create each generation
#' @param parallel A logical argument specifying if parallel computing should be used (TRUE) or not (FALSE, default) for evaluating the fitness function. You can also specifiy the number of cores to use. Parallel processing currently only works when optimizing using least cost paths. It will fail if used with CIRCUITSCAPE, so this is currently not an option.
#' @param run Number of consecutive generations without any improvement in AICc before the GA is stopped (Default = 25)
#' @param keepBest A logical argument specifying if best solutions at each iteration should be saved (Default = TRUE)
#' @param seed Integer random number seed to replicate \code{ga} optimization
#' @param quiet Logical. If TRUE, AICc and step run time will not be printed to the screen after each step. Only \code{ga} summary information will be printed following each iteration. Default = FALSE
#' @return An R object that is a required input into optimization functions
#'
#' @details Only files that you wish to optimize, either in isolation or simultaneously, should be included in the specified \code{ASCII.dir}. If you wish to optimize different combinations of surfaces, different directories contaiing these surfaces must be created.
#'
#' When \code{scale = TRUE}, the standard deviation of the Gaussian kernel smoothing function (sigma) will also be optimized during optimization. Only continuous surfaces or binary categorical surfaces (e.g., forest/no forest; 1/0) surfaces can be optimized when \code{scale = TRUE}
#' 
#' \code{scale.surfaces} can be used to specify which surfaces to apply kernel smoothing to during multisurface optimization. For example, \code{scale.surfaces = c(1, 0, 1)} will result in the first and third surfaces being optimized with a kernel smoothing function, while the second surface will not be scaled. The order of surfaces will match either the order of the raster stack, or alphabetical order when reading in from a directory.
#' 
#' The Default for \code{k.value} is 3, which sets k equal to the number of parameters optimized plus the number of surfaces optimized, plus 1 for the intercept term. Prior to version 3.0-0, \code{k.value} could not be specified by the user and followed setting 2, such that k was equal to the number of parameters optimized plus the intercept term.
#'
#' \code{cont.shape} can take values of "Increase", "Decrease", or "Peaked". If you believe a resistance surface is related to your response in a particular way, specifying this here may decrease the time to optimization. \code{cont.shape} is used to generate an initial set of parameter values to test during optimization. If specified, a greater proportion of the starting values will include your believed relatiosnship. If unspecified (the Default), a completely random set of starting values will be generated.
#'
#' If it is desired that only certain transformations be assessed for continuous surfaces, then this can be specified using \code{select.trans}. By default, all transformations will be assessed for cntinuous surfaces unless otherwise specified. Specific transformations can be specified by providing a vector of values (e.g., \code{c(1,3,5)}), with values corresponding to the equation numbers as detailed in \code{\link[ResistanceGA]{Resistance.tran}}. If multiple rasters are to be optimized from the same directory, then a list of transformations must be provided in the order that the raster surfaces will be assessed. For example:\cr
#' \code{select.trans = list("M", "A", "R", c(5,6))}\cr
#' will result in surface one only being optimized with Monomolecular transformations, surface two with all transformations, surface three with only Ricker transformations, and surface four with Reverse Ricker and Reverse Monomolecular only. If a categorical surface is among the rasters to be optimized, it is necessary to specify \code{NA} to accomodate this.
#'
#' It is recommended to first run GA optimization with the default settings

#' @export
#' @author Bill Peterman <Bill.Peterman@@gmail.com>
#' @usage GA.prep(ASCII.dir,
#' Results.dir = NULL,
#' min.cat = 1e-04,
#' max.cat = 2500,
#' max.cont = 2500,
#' min.scale = NULL,
#' max.scale = NULL,
#' cont.shape = NULL,
#' select.trans = NULL,
#' method = "LL",
#' scale = FALSE,
#' scale.surfaces = NULL,
#' k.value = 3,
#' pop.mult = 15,
#' percent.elite = 0.05,
#' type = "real-valued",
#' pcrossover = 0.85,
#' pmutation = 0.125,
#' maxiter = 1000,
#' run = 25,
#' keepBest = TRUE,
#' population = gaControl(type)$population,
#' selection = gaControl(type)$selection,
#' crossover = "gareal_blxCrossover",
#' mutation = gaControl(type)$mutation,
#' pop.size = NULL,
#' parallel = FALSE,
#' seed = NULL,
#' quiet = FALSE)

GA.prep <- function(ASCII.dir,
                    Results.dir = NULL,
                    min.cat = 0.0001,
                    max.cat = 2500,
                    max.cont = 2500,
                    min.scale = NULL,
                    max.scale = NULL,
                    cont.shape = NULL,
                    select.trans = NULL,
                    method = "LL",
                    scale = FALSE,
                    scale.surfaces = NULL,
                    k.value = 3,
                    pop.mult = 15,
                    percent.elite = 0.05,
                    type = "real-valued",
                    pcrossover = 0.85,
                    pmutation = 0.125,
                    maxiter = 1000,
                    run = 25,
                    keepBest = TRUE,
                    population = gaControl(type)$population,
                    selection = gaControl(type)$selection,
                    crossover = "gareal_blxCrossover",
                    mutation = gaControl(type)$mutation,
                    pop.size = NULL,
                    parallel = FALSE,
                    seed = NULL,
                    quiet = FALSE) {
  if(scale == FALSE) {
    scale <- NULL
  }
  
  if (!is.null(Results.dir)) {
    TEST.dir <- !file_test("-d", Results.dir)
    if (TEST.dir == TRUE) {
      stop("The specified 'Results.dir' does not exist")
    }
  }
  
  if ((class(ASCII.dir)[1] == 'RasterStack' |
       class(ASCII.dir)[1] == 'RasterLayer') & is.null(Results.dir)) {
    warning(paste0(
      "'Results.dir' was not specified. Results will be exported to ",
      getwd()
    ))
    Results.dir <- getwd()
  }
  
  if (class(ASCII.dir)[1] != 'RasterStack' & is.null(Results.dir)) {
    Results.dir <- ASCII.dir
  }
  
  if (class(ASCII.dir)[1] == 'RasterStack' |
      class(ASCII.dir)[1] == 'RasterLayer') {
    r <- ASCII.dir
    names <- names(r)
    n.layers <- length(names)
  } else {
    ASCII.list <-
      list.files(ASCII.dir, pattern = "*.asc", full.names = TRUE) # Get all .asc files from directory
    if (length(ASCII.list) == 0) {
      stop("There are no .asc files in the specified 'ASCII.dir")
    }
    r <- stack(lapply(ASCII.list, raster))
    names <-
      gsub(pattern = "*.asc", "", x = (list.files(ASCII.dir, pattern = "*.asc")))
    n.layers <- length(ASCII.list)
  }
  
  if(is.null(scale.surfaces) && !is.null(scale)) {
    scale.surfaces <- rep(1, n.layers)
  }
  
  if(is.null(scale.surfaces) && is.null(scale)) {
    scale.surfaces <- rep(0, n.layers)
  }
  
  if(length(scale.surfaces) != n.layers) {
    stop("The 'scale.surfaces' vector is not the same length as the number of layers")
  }
  
  if ("Results" %in% dir(Results.dir) == FALSE)
    dir.create(file.path(Results.dir, "Results"))
  #   dir.create(file.path(ASCII.dir, "Results"),showWarnings = FALSE)
  Results.DIR <- paste0(Results.dir, "Results/")
  if ("tmp" %in% dir(Results.dir) == FALSE)
    dir.create(file.path(Results.dir, "tmp"))
  #   dir.create(file.path(Results.dir, "tmp"),showWarnings = FALSE)
  Write.dir <- paste0(Results.dir, "tmp/")
  if ("Plots" %in% dir(Results.DIR) == FALSE)
    dir.create(file.path(Results.DIR, "Plots"))
  #   dir.create(file.path(Results.dir, "tmp"),showWarnings = FALSE)
  Plots.dir <- paste0(Results.DIR, "Plots/")
  
  # Determine total number of parameters and types of surfaces included
  parm.type <- data.frame()
  min.list <- list()
  max.list <- list()
  SUGGESTS <- list()
  eqs <- list()
  for (i in 1:n.layers) {
    n.levels <- length(unique(r[[i]]))
    
    if (n.levels <= 15 &
        n.levels > 2 &
        !is.null(scale) &
        scale.surfaces[i] == 1) {
      stop(
        "Kernel smoothing can only be applied to binary (1/0) categorical or feature surfaces. Please refer to 'Details' of the `GA.prep` function or the Vignette for help."
      )
    }
    
    if (n.levels == 2 & !is.null(scale) & scale.surfaces[i]==1) {
      parm.type[i, 1] <- "cont"
      parm.type[i, 2] <- 4
      parm.type[i, 3] <- names[i]
      
      if (is.null(min.scale)) {
        min.scale <- 0.3

      }
      if (is.null(max.scale)) {
        max.scale <- max(dim(r[[i]])) / 2
      }
      
      min.list[[i]] <-
        c(1, 0.001, 0.001, min.scale) # eq, shape/gaus.opt, max, gaus.sd
      max.list[[i]] <- c(9.99, 15, max.cont, max.scale)
      
      # if(!is.null(scale)) {
      #   if(is.null(min.scale)) { min.scale <- 1 }
      #   if(is.null(max.scale)) { max.scale <- max(dim(r[[i]])) }
      # }
      
      if (is.null(select.trans)) {
        eqs[[i]] <- eq.set("A")
      } else {
        eqs[[i]] <- eq.set(select.trans[[i]])
      }
      
    } else if (n.levels <= 15) {
      Level.val <- unique(r[[i]])
      parm.type[i, 1] <- "cat"
      parm.type[i, 2] <- n.levels
      parm.type[i, 3] <- names[i]
      min.list[[i]] <- c(1, rep(min.cat, (n.levels - 1)))
      max.list[[i]] <- c(1, rep(max.cat, (n.levels - 1)))
      
      eqs[[i]] <- NA
      
    } else {
      parm.type[i, 1] <- "cont"
      if (!is.null(scale)  & scale.surfaces[i]==1) {
        parm.type[i, 2] <- 4
        
        if (is.null(min.scale)) {
          min.scale <- 0.3

        }
        if (is.null(max.scale)) {
          max.scale <- max(dim(r[[i]]))
        }
        
        min.list[[i]] <-
          c(1, 0.001, 0.001, min.scale) # eq, shape/gaus.opt, max, gaus.sd
        max.list[[i]] <- c(9.99, 15, max.cont, max.scale)
        
      } else {
        parm.type[i, 2] <- 3
        min.list[[i]] <-
          c(1, 0.001, 0.001) # eq, shape/gaus.opt, max

        max.list[[i]] <- c(9.99, 15, max.cont)
      }
      
      parm.type[i, 3] <- names[i]
      
      if (is.null(select.trans)) {
        eqs[[i]] <- eq.set("A")
      } else {
        eqs[[i]] <- eq.set(select.trans[[i]])
      }
    }
  }
  
  
  colnames(parm.type) <- c("type", "n.parm", "name")
  parm.index <- c(0, cumsum(parm.type$n.parm))
  ga.min <- unlist(min.list)
  ga.max <- unlist(max.list)
  surface.type <- parm.type$type
  
  if (is.null(pop.size)) {
    if (length(ga.min) < 10) {
      pop.size <- min(c(15 * length(ga.min), 100))
    } else {
      pop.size <- 10 * length(ga.min)
    }
  }
  
  for (i in 1:length(surface.type)) {
    if (surface.type[i] == "cat" & !is.null(scale) & scale.surfaces[i] == 1) {
      SUGGESTS[[i]] <-
        sv.cont.nG(
          "NA",
          pop.size = pop.size,
          max = max.cont,
          scale = scale,
          max.scale = max.scale
        )
      
    } else if (surface.type[i] == "cat") {
      SUGGESTS[[i]] <-
        sv.cat(levels = parm.type[i, 2],
               pop.size = pop.size,
               min.cat,
               max.cat)
      
    } else if (exists("cont.shape") &&
               length(cont.shape > 0) && !is.null(scale) && scale.surfaces[i] == 1) {
      SUGGESTS[[i]] <-
        sv.cont.nG(
          "NA",
          pop.size = pop.size,
          max = max.cont,
          scale = scale,
          max.scale = max.scale
        )
      cont.shape <- cont.shape#[-1]
      
    } else if (exists("cont.shape") && length(cont.shape > 0)) {
      SUGGESTS[[i]] <-
        sv.cont.nG(cont.shape[1], pop.size = pop.size, max.cont)
      cont.shape <- cont.shape[-1]
      
    } else if (!is.null(scale) && scale.surfaces[i] == 1) {
      SUGGESTS[[i]] <-
        sv.cont.nG(
          "NA",
          pop.size = pop.size,
          max = max.cont,
          scale = scale,
          max.scale = max.scale
        )
    } else {
      SUGGESTS[[i]] <- sv.cont.nG("NA", pop.size = pop.size, max.cont)
    }
  }
  SUGGESTS <-
    matrix(unlist(SUGGESTS),
           nrow = nrow(SUGGESTS[[1]]),
           byrow = F)
  
  if (method != "AIC") {
    Min.Max <- 'min'
  } else {
    Min.Max <- 'max'
  }
  
  list(
    parm.index = parm.index,
    ga.min = ga.min,
    ga.max = ga.max,
    select.trans = eqs,
    scale = scale,
    scale.surfaces = scale.surfaces,
    surface.type = surface.type,
    parm.type = parm.type,
    Resistance.stack = r,
    n.layers = n.layers,
    layer.names = names,
    pop.size = pop.size,
    min.list = min.list,
    max.list = max.list,
    SUGGESTS = SUGGESTS,
    ASCII.dir = ASCII.dir,
    Results.dir = Results.DIR,
    Write.dir = Write.dir,
    Plots.dir = Plots.dir,
    type = type,
    pcrossover = pcrossover,
    pmutation = pmutation,
    crossover = crossover,
    maxiter = maxiter,
    run = run,
    keepBest = keepBest,
    population = population,
    selection = selection,
    mutation = mutation,
    parallel = parallel,
    pop.mult = pop.mult,
    percent.elite = percent.elite,
    Min.Max = Min.Max,
    method = method,
    k.value = k.value,
    seed = seed,
    quiet = quiet
  )
}