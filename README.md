# AWS Sandboxes

[![Known Vulnerabilities](https://snyk.io/test/github/svenfinke/aws_sandboxes/badge.svg)](https://snyk.io/test/github/svenfinke/aws_sandboxes)



Managing Accounts in AWS - or more so: creating and deleting accounts in AWS - can be a huge pain in the ass. A secure AWS Account should have MFA activated on the root credentials, security questions and contacts should be defined and to make sure the financial department is not hunting you down for dozens of separate invoices, you should change the name of the account owner - which defaults to the account name (WHY?). And this is only where the fun starts. Did you ever try tu unroll an account? No? Trust me. It's a lot of fun! To make matters even worse: Most of this is not possible with the API. So it has to be done manually. NICE.

In most cases, this isn't even a problem. Customers will most likely get a few accounts and they keep them. Have you ever heard of the phrase "pets vs. cattle"? This is e.g. about the differernce of maintaining servers over a long time and keeping them updated (taking care of them like you take care of your pet) versus short living servers which are replaced if they make trouble (just as in a cattle. You might be willed to take some care, but sick animals will most likely be replaced sooner than later). Putting this into the AWS Account context: I'd like to have sandboxes that are cattle. Just spin them up and delete them when they are not needed anymore. But as I mentioned earlier, this is not really possible in AWS.

## Pet Sandboxes
I have to work around this problem a little bit. The Sandbox accounts itself will live basically forever, but they are wiped clean every few weeks or if triggered. But wiping an account is not an easy task either. In this case I'd like to utilize aws-nuke, a tool developed by rebuy-de. I will have to make some changes to make it work in this project, but that should not be a problem.

# Technologies

To realize this I want to go with either terraform or CDK to create the infrastructure, React for the frontend and stepfunctions to create the necessary workflows to create and wipe sandboxes. Cognito will take care of the authentication and will utilize Azure AD in the future - hopefully.