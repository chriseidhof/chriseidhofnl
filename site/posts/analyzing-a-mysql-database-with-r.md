---
aliases:
  - /posts/analyzing-a-mysql-database-with-r.html
date: 2011-07-22
title: Analyzing a MySQL database with R
---

In this article, we analyze a MySQL database which contains soccer transfer
data, using the R environment, on OS X. We show in a few simple steps how you
can link the two together.&#10;

** ** **Prerequisites**&#10;

Make sure you have a recent version of MySQL, and the latest version of R
installed. As our graphical user interface, we use
[RStudio](http://rstudio.org/). From RStudio you can install the MySQL package:
`install.packages("RMySQL")`. If this doesn’t work for you, please refer to the
[installation instructions](http://biostat.mc.vanderbilt.edu/wiki/Main/RMySQL).
For plotting, install the ggplot2 library by issueing a
`install.packages("ggplot2")` in RStudio. Alternatively, you can use the
graphical interface: in the bottom right panel, choose ‘Packages’ and click
‘Install Packages’. This presents you with a dialog to choose a
[CRAN](http://cran.r-project.org/) mirror, and a prompt where you can enter the
package name.&#10;

**Analysis**

Our MySQL database contains a table `transactions`, which contains transaction
data. The `transactions` table has a column `transfer_value` of type `float`,
which is what we are interested in. First, we generate a big list of all the
transactions: `SELECT transfer_value FROM transactions`, which generates a MySQL
table with a single column that contains the transaction data.&#10;

First, let’s make sure the MySQL library is imported:&#10;

``` 
> library(RMySQL)
```

Next, we connect to our database, which is named `soccer`:&#10;

``` 
> con <- dbConnect(MySQL(), dbname="soccer")
```

Now we can start to issue queries:&#10;

``` 
> transfer_values <- dbGetQuery(con, "select transfer_value from transactions")
> summary(transfer_values)
transfer_value    
Min.   :    5900  
1st Qu.:  500000  
Median : 1700000  
Mean   : 3688301  
3rd Qu.: 4500000  
Max.   :94000000
```

This shows us a summary of the transfer values. The maximum is 94 million, which
was Cristiano Ronaldo’s transfer to Real Madrid. To look at how the numbers are
distributed, we can plot them in a graph, using the `qplot` function from the
`ggplot2` library, which is a convenience function that quickly generates
`ggplot` plot objects.&#10;

``` 
> library(ggplot2)
> qplot(transfer_values$transfer_value)
```

This gives us a nice picture, which looks like a [Power
Law](http://en.wikipedia.org/wiki/Power_law):&#10;

![](http://media.tumblr.com/tumblr_loqsvzES871ql6bph.png)

If we zoom in on the transfers up to 10 million, we get a more detailed picture,
showing peaks at regular intervals: apparently, the soccer negotiators like nice
round numbers too.&#10;

``` 
> qplot(transfer_values$transfer_value, xlim=c(0,1e07), binwidth=1e05, ylim=c(0,500))
```

![](http://media.tumblr.com/tumblr_loqswmkrnV1ql6bph.png)

For more info on the `qplot` command, you can type `help(qplot)`, and RStudio
will show you the relevant help page on the bottom right.&#10;

**Conclusion**

Even though we did very basic analysis of the data, we have seen how to connect
R to MySQL and how to use the `ggplot2` library to visualize the data.&#10;

Thanks to [Peter Tegelaar](http://ptegelaar.nl/) for reading a draft of this
post and helping with the code.&#10;

*Update:* see [Hacker News](http://news.ycombinator.com/item?id=2828176) for the
discussion.&#10;
