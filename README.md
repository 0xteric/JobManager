# 🧠 JobManager Smart Contract

A smart contract for managing freelance jobs on the blockchain. It allows clients to post jobs, freelancers to apply, and admins to assist or cancel jobs when necessary.

## ✨ Features

- ✅ Clients can post jobs with a defined budget
- 💸 Clients can deposit the budget to secure payment
- 🙋 Freelancers can apply to open jobs with a proposal and budget
- 🧑‍⚖️ Clients select a freelancer from the applicants
- ✅ Once completed, freelancers receive the payment
- 🛡️ Admins can be assigned to moderate and cancel jobs if needed

## 🔐 Roles

- **Client**: Posts and manages their job offers.
- **Freelancer**: Applies to jobs with proposals.
- **Admin**: Can resolve or cancel jobs, and manage access.

## 🔧 Main Functions

- `postJob(title, description, budget)`: Post a new job offer.
- `depositBudget(jobId)`: Deposit ETH for the job's budget.
- `applyToJob(jobId, proposal, proposalBudget)`: Submit a proposal to a job.
- `selectFreelancer(jobId, freelancer)`: Select a freelancer for the job.
- `finishJob(jobId)`: Mark the job as done and transfer funds to the freelancer.
- `killJob(jobId)`: Cancel the job and return the deposit to the client.
- `addAdmin(address)`: Add a new admin (only callable by existing admins).
- `addJobAdmin(jobId)`: Assign an admin to a specific job.
- `callAdmin(jobId)`: Notify admins to intervene.

## 📦 Storage

Each job stores:

- Job metadata (title, description, budget, status)
- Client and selected freelancer addresses
- Applicants list and their proposals (via mapping)
- Assigned admin

## 🧪 Testing

Use [Foundry](https://book.getfoundry.sh/) to test:

```bash
forge test
forge coverage
