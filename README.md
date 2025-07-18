# Charity Donation Tracking System

A comprehensive blockchain-based system for tracking charitable donations, fund allocation, impact measurement, and transparency reporting built on the Stacks blockchain using Clarity smart contracts.

## System Overview

This system consists of five interconnected smart contracts that provide end-to-end tracking of charitable donations:

### 1. Donation Receipt Contract (`donation-receipt.clar`)
- Records all donor contributions with timestamps
- Calculates and stores tax benefit information
- Maintains donor history and total contribution amounts
- Provides donation verification for tax purposes

### 2. Fund Allocation Contract (`fund-allocation.clar`)
- Manages distribution of donated funds to specific causes
- Tracks allocation percentages and amounts
- Maintains cause categories and funding targets
- Provides allocation history and remaining balances

### 3. Impact Measurement Contract (`impact-measurement.clar`)
- Tracks charitable outcome effectiveness metrics
- Records measurable results from funded programs
- Calculates impact ratios and success rates
- Stores beneficiary count and outcome data

### 4. Transparency Reporting Contract (`transparency-reporting.clar`)
- Publishes detailed spending reports
- Tracks administrative costs vs. program costs
- Provides public access to financial data
- Maintains quarterly and annual reporting

### 5. Beneficiary Verification Contract (`beneficiary-verification.clar`)
- Validates aid recipient eligibility
- Manages beneficiary registration and status
- Tracks aid distribution to verified recipients
- Prevents duplicate aid distribution

## Key Features

- **Immutable Records**: All donations and allocations are permanently recorded on-chain
- **Tax Compliance**: Automatic calculation of tax-deductible amounts
- **Real-time Tracking**: Live updates on fund allocation and impact metrics
- **Transparency**: Public access to spending and results data
- **Fraud Prevention**: Beneficiary verification prevents duplicate aid
- **Impact Measurement**: Quantifiable metrics for charitable effectiveness

## Data Types

### Donation Record
- Donor principal
- Amount donated
- Timestamp
- Tax benefit amount
- Cause category

### Fund Allocation
- Cause identifier
- Allocated amount
- Target amount
- Allocation percentage
- Status (active/completed)

### Impact Metrics
- Program identifier
- Beneficiaries served
- Outcome measurements
- Success rate
- Cost per beneficiary

### Transparency Report
- Reporting period
- Total funds received
- Program costs
- Administrative costs
- Impact summary

### Beneficiary Profile
- Beneficiary identifier
- Verification status
- Aid received
- Last distribution date
- Eligibility criteria met

## Error Codes

- `ERR-NOT-AUTHORIZED (u100)`: Caller lacks required permissions
- `ERR-INVALID-AMOUNT (u101)`: Invalid donation or allocation amount
- `ERR-CAUSE-NOT-FOUND (u102)`: Specified cause does not exist
- `ERR-INSUFFICIENT-FUNDS (u103)`: Not enough funds for allocation
- `ERR-ALREADY-EXISTS (u104)`: Record already exists
- `ERR-INVALID-BENEFICIARY (u105)`: Beneficiary not verified or eligible
- `ERR-INVALID-PERIOD (u106)`: Invalid reporting period
- `ERR-DUPLICATE-DISTRIBUTION (u107)`: Aid already distributed to beneficiary

## Usage Examples

### Making a Donation
\`\`\`clarity
(contract-call? .donation-receipt record-donation u1000000 "education")
\`\`\`

### Allocating Funds
\`\`\`clarity
(contract-call? .fund-allocation allocate-funds "education" u500000)
\`\`\`

### Recording Impact
\`\`\`clarity
(contract-call? .impact-measurement record-impact "education-program-1" u150 u140)
\`\`\`

### Verifying Beneficiary
\`\`\`clarity
(contract-call? .beneficiary-verification verify-beneficiary "beneficiary-123")
\`\`\`

## Testing

Run the test suite with:
\`\`\`bash
npm test
\`\`\`

Tests cover all contract functions, error conditions, and integration scenarios.

## Deployment

1. Install Clarinet CLI
2. Run \`clarinet check\` to validate contracts
3. Deploy to testnet: \`clarinet deploy --testnet\`
4. Deploy to mainnet: \`clarinet deploy --mainnet\`

## Security Considerations

- All functions include proper authorization checks
- Input validation prevents invalid data entry
- Beneficiary verification prevents fraud
- Immutable records ensure data integrity
- Public transparency maintains accountability
- 
