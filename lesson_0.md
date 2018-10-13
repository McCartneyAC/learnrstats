# Lesson 0: Downloading R. Rstudio. Packages. 

## Hi everyone!

I was blown away by the enthusiasm people expressed about learning R, so I dreamed up this idea overnight and I'm going to post a few basic, foolproof guides going into R. Many of you are about to take R-based classes this semester so hopefully this will provide a forum for troubleshooting any R problems as well

## Downloading R

To download R, go to the [front page of their website](https://www.r-project.org/) and follow the instructions. The first step is choosing a CRAN mirror. CRAN is the Comprehensive R Archive Network. This body of data/documents is mirrored at many research institutions all over the world so that if one fails, there are many backups. Choose a CRAN mirror near you (the closest to me is Tennessee) and follow the instructions there.

Once you're at a [CRAN mirror page,](http://lib.stat.cmu.edu/R/CRAN/) follow the instructions there for Mac, Windows, or Linux.

You may notice that the names of the R versions are really funny. When I first learned R, it was "Bug in your Hair" and now we're up to "Feather Spray." For some reason, all the versions of R are named for jokes from Peanuts cartoons. I don't know if anyone actually has an archive pairing each R update to its cartoon, but I'd love to see one.

Once you've downloaded R to your computer, you don't need to ever open it again, because we're going to access R from RStudio!

## Downloading RStudio

RStudio is an IDE, an integrated development environment. It's a program that exists solely to make using R easier for you. Once we've downloaded it, I'll explain more how to use it, but know that it's a sine qua non of R usage. Very few people use anything else, and we regard them as kind of funny :)

[Access the download instructions for Rstudio here. ](https://www.rstudio.com/products/rstudio/download/#download) Follow the instructions relevant for your computer and operating system.

When you first open Rstudio, it should look like this, with 4 panes. If you only have three, it's probably because you don't have a script page open yet (my top left here) and you can open a new one by clicking the black-page icon under "File" above.

The panes are as follows, starting clockwise from the top right:
![](https://i.redd.it/lc70hn191vg11.png)

* top right: Your Environment. This tells you what objects, functions, datasets, etc that you have available to you or have defined yourself. When you load data, it will appear here. When you make a user-defined-function, here it will be. This is useful for seeing an at-a-glance of what you can do stuff with. I don't tend to use it much
* Bottom right: Packages, Viewer, Help. These are super-useful to the user! Mine is set to packages right now, which I'll explain more about below. Viewer is where any graphs plots diagrams etc that you make will show up. Help allows you to see documentation for any packages or functions you wish to use, so if you can't remember how to reshape your data, you'll check there for a short guide/reminder.
* Bottom Left: Console and Terminal. If you're a super-user, you might spend a lot of time here. For a first-timer, it's easier enough to think of this as a place where your output will appear. The console is how R replies to you when you ask it a question or ask it to do something.
* Top Left: Your scripts. These are files or copy-pastable bits of code. You don't have to run them all at once like is the preferred method in stata. They're like programs but in general you tend to only run them piece-by-piece. This is where you edit your complex code and do most of your thinking and work.

If you're an excel user, you might be asking, where do I see the spreadsheet????? In R, the spreadsheet (data table) isn't typically within your view because you aren't usually concerned with individual data points--you're trying to learn about all of them together. Excel forces you do do your calculations on the same sheet that your data lives on, which is nonsensical--those calculations aren't part of your data! in R they're separate, and we spend most of our time thinking about the calculations, not staring at the raw data.

## Packages

The best thing about R and Rguably what makes it so powerful, popular, and perennial is its package system. R comes pre-installed with some packages like `nnet` and `lattice` but in general  the user-written packages blow the pre-installed packages out of the water. We generally only use `base`  and `stats` from the pre-installed list.

So how do you get more packages? Easy!
```
# type this into your open script (the top left pane)
# then, when your cursor is on the line, click control + enter (or command + enter on a mac)
# and that will execute your code. 
install.packages("devtools")

# devtools is a package that will allow us to do some more complex programming later
# but its main utility for us now is that it will allow us to download user packages from 
# github. 
```
And just like that, you've downloaded your first package! How did R know where to look? Unless otherwise specified, R goes to the nearest CRAN mirror and looks there. Devtools is available on the CRAN, so voila it worked!

We're going to download one more package then call lesson 0 over. This package takes a while to download, so hit control + enter then go make yourself a cuppa tea.

# Tidyverse is a 'meta-package' in that all it does is download and organize other packages
# for you that are built to exist in one big ecosystem--the tidyverse. 

# Since 2012 or so, R has had something of a revolution and most of the cutting-edge work in the 
# language is being done with this programming style as its base. Older documents and academic
# work often ignore it and are written in a difficult, convoluted style as a result. 
    
# the goal of the tidyverse is to force you to do your data analysis in a clean, consistent, well-
# organized paradigm that doesn't cause you to have to translate back-and-forth between coding and
# analysis, but instead allows you to think about your analysis while coding without interruption. 
    
install.packages("tidyverse")
```
