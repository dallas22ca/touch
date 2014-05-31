When someone uploads a contact list
- select file
- choose Add To Courses If Necessary
- click Upload

When someone creates a new Task
- should see todays task list
- should be able to get to list for any date
- fill content
- select date
- click Save Task

When someone wants to create a course/sequence/path
- click Create Course
- fill in name
- choose Update Current Contacts
- set trigger event
  - before/after/on birthday (only one that allows Before) :: date_based
  - manual
  - every 3 weeks for Segment
  - join segment
- immediately, send "I like {{ contact.favourite_food }}"
- immediately, create task "Research {{ contact.favourite_food }} for {{ contact.name }}."
- 2 days after, create task "Phone {{ contact.name }} to ask if likes cake"
- 3 days after, send "Ice cream is a great choice as well!"
- 4 days after, mark field BeenCoursed as true
- 5 days after, put on different course if FirstName is "Dallas"
- 6 days after, send a postcard
- click Save and Add People To Course
Q: What happens if they join again halfway through? Ignored. At the end? Begin. Courseships counted.
Q: One course at a time? No.
Q: Option for 1 email a day?
Q: What happens when a course is deleted? Can only be archived. Remove future Tasks and Messages.

When someone wants to add people to a course
- click Contact Name
- click Add To Course
- select Course Name
- click Start Course

When someone wants to add a group of people to a course
- select Segment
- click Add To Course
- select Course Name
- click Start Course

When someone subscribes to newsletter
- course started