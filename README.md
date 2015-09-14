This is a set of functions and scripts for a) extracting all human-written text from pull requests, b) cleaning and structuring the data in a well-organized way, and c) performing text mining (topic modeling) on the dataset so as to classify distinct text comments into conceptual categories.

## Requirements
* Use the package 'rgithub' to extract the data
* Extract all the text comments for each pull request for a single project
* Retain timestamps and pull request ids for each comment
* Use a topic modeling approach to classify comments into different topics
* Use the package 'LDAvis' to visualize multiple topic modeling solutions
* Provide ways to correlate topics with other code metrics

# Modus Operandi
A couple of notes on how we work:

* We will be working using a pull request model. This will allow me to review and understand the code you write as we go along.
* All scripts needs to run as-is on my machines (2 macs)
* The following style guide applies: http://adv-r.had.co.nz/Style.html
* Remember that we are writing scripts, not doing interactive work, so commands which print things to the interactive shell should be avoided
* The project will be open source, so you can use it in your resume.
* Default is R, if necessary we go to Python.
* Code should be well-commented and use variable and function names which are intuitive and easy to understand
