% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datastore.R
\name{initDatastoreH5}
\alias{initDatastoreH5}
\title{Initialize Datastore for an HDF5 (H5) type datastore.}
\usage{
initDatastoreH5(AppendGroups = NULL)
}
\arguments{
\item{AppendGroups}{a character string identifying the names of groups to add
to an existing datastore. The default value is NULL. If the value is NULL,
a new datastore will be created. If an existing datastore has the same name
as that defined for the model run, it will be deleted. The datastore will
have a 'Global' group established in it as well as a group for each year
identified in the model run years. If append is a character vector of group
names, the groups identified in the character string will be added to the
datastore.}
}
\value{
TRUE if datastore initialization is successful. Calls the
listDatastore function which adds a listing of the datastore contents to the
model state file.
}
\description{
\code{initDatastoreH5} a visioneval framework datastore connection function
that creates datastore with starting structure for an HDF5 (H5) type
datastore.
}
\details{
This function creates the datastore for the model run with the initial
structure for an HDF5 (H5) type datastore. Alternately, if the value of
the AppendGroups parameter is not NULL the function will add the group or
groups identified by this parameter to an existing datastore.
}
