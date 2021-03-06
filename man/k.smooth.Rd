% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/k_smooth.R
\name{k.smooth}
\alias{k.smooth}
\title{Kernel smoothing function}
\usage{
k.smooth (raster, sigma, SCALE)
}
\arguments{
\item{raster}{A RasterLayer object to be smoothed}

\item{sigma}{The standard deviation of the Gaussian smoothing parameter (see \code{\link[smoothie]{kernel2dsmooth}} documentation in the \code{smoothie} package.)}

\item{SCALE}{Logical. Should the smoothed raster surface be scaled to range from 0-10 (Default = FALSE)}
}
\description{
Apply Gaussian kernel smoothing of specified sigma
}
\details{
The sigma parameter indicates the standard deviation of the Gaussian smoothing function. Note that sigma is in raster cells, not spatial units.
}
\author{
Bill Peterman <Bill.Peterman@gmail.com>
}
