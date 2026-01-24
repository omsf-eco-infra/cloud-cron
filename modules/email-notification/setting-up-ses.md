# Setting up SES email on AWS

To set up Amazon Simple Email Service (SES) for sending email notifications, you'll need to validate control of both an email address and a sending domain.

This document gives a quick overview of the process; you can follow the step-by-step wizard by going to the AWS SES Console and clicking "Get Started." 

## Step 1: Validate an Email Address

Once you go through the wizard, an email will be sent to the address you provided. Click the link to validate!

## Step 2: Validate a Sending Domain

After going through the wizard, AWS will provide you with several DNS records to add. This will include 3 DKIM (CNAME) records, and a TXT record for DMARC. Add these records to your domain's DNS settings.

### Step 3: Test from within the Sandbox

Initially, you'll be in a sandbox environment, with limited permissions. Note that you need to verify any email addresses you want to send to while in the sandbox. You can add identities in the "Identities" section of the SES console.

### Step 4: Move out of the Sandbox
