
# Importing Questions into Qualtrics Using R
# D. J. van Os 
# 04/02/2021

# Install relevant libraries (uncomment if you have not yet installed this)
# install.packages("tidyverse")

# Load relevant libraries
library(tidyverse)

####-------------------####
#### Prepare your data ####
####-------------------####

# Import the data into R 
poetry <- read_csv("Poetry.csv")

# Check out the data
view(poetry)

# Or alternatively
glimpse(poetry)

# 1. Remove the first two rows, which are not responses, and 
# 2. keep only columns we want to import back into Qualtrics 
# (the question and their response ID, which we can use to link back to the respondent), and
# 3. Remove any participants who did not respond
poetry <- poetry %>% 
  slice(-c(1:2)) %>% 
  select(ResponseId, poetry) %>% 
  filter(!is.na(poetry))

# Check out the data again
view(poetry)

####-------------------------------------####
#### Add instructions for Qualtrics data ####
####-------------------------------------####

# Add the instructions Qualtrics will need to import the data

# Qualtrics instructions for formatting Block 1 and the start of Block 2
block_1 <- 
  "
[[AdvancedFormat]]

[[Block: Instructions]]

[[Question:Text]]

<b> Instructions </b> 
<BR>
We have gathered some experts to write some poetry for us, and we need your opinions on their poetry. 
Please read their poetry carefully and be honest in your answers.

[[Block:Poetry Ratings]] "

# Qualtrics instructions for formatting Block 3 (the last block)
block_3 <- 
  "[[Block:Debrief]]

[[Question:Text]]

[[ID:debrief]]

Thank you for your participation! "


# Add the Qualtrics instructions for formatting before each poem:
before_poem_1 <-
  "[[Question:Text]]
[[ID:"

# Add the Qualtrics instructions for formatting between the ID and the poem: 
before_poem_2 <- 
  "-a]]

Poem: "

# Add the Qualtrics instructions for formatting after the poem: 
after_poem_1 <- 
  
  "

[[Question:TextEntry]]

[[ID:"

after_poem_2 <- 
  
  "-b]]

What are your initial thoughts about his poem? 

[[Question:MC:SingleAnswer:Horizontal]]

[[ID:"

after_poem_3 <- 
  
  "-c]]

How would you rate this poetry?

[[Choices]]

1 - Why did they even bother submitting.
2 
3 
4 
5 
6 
7 - The most beautiful thing I've ever read."


####----------------------------------------------####
#### Combine Qualtrics Instructions and Responses ####
####----------------------------------------------####

# This creates a column which contains all the required information for
# each response to be rated. ResponseId appears multiple times because 
# it must be specified for each question (e.g. ID 1a, 1b, and 1c).
poetry <- poetry %>% 
  mutate(formatted = paste0(before_poem_1, 
                            ResponseId, 
                            before_poem_2,
                            poetry,
                            after_poem_1,
                            ResponseId,
                            after_poem_2, 
                            ResponseId,
                            after_poem_3)) 

# Combine with block 1 and block 3 text to create one big object ready to be exported
formatted <- c(block_1, poetry$formatted, block_3)

####---------------------------####
#### Export Prepared Text File ####
####---------------------------####

write.table(formatted, file = "formatted.txt", quote=FALSE, col.names = FALSE, row.names = FALSE, na = "")
