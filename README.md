# ICMDATA scripts
A set of scritps to process user certificate dat from ICM and directory data
from Directory Services, producing data files to drive bulk certificate
updates for OCSP.

# ocsp.sh
A script that processes the raw data and produces files to
support the update process.

## Inputs

### Departments.csv
The control file that drives the script in comma-separated values
(CSV) format with the following columns:
1. Organizational Unit (omit the ou=) 
2. Department Acronym (used for output data file names)
3. Maxumum daily volume
4. Schedule method (1 = ICM-Managed, 0 = Partner-Managed)

The first row is a header row and is ignored.

Multiple lines can re-use the same Department Acronym so
that multiple OUs can be consolidated to a single set of
output files.

### AllDepts.csv
A concatenated dump of certificate data exported by the ICM team
in comma-separated values (CSV) format with the following columns:
1. Organizational Unit (ou=XXX)
2. Device flag (1 = device, 0 = user)
3. Distinguished Name
4. State (Activated, Recover, Deactivated)
5. Subject Alternate Names (email addresses)
6. Ignored
7. Ignored
8. Expiration date. YYYY-MM-DD
9. Rollover Allowed (TRUE or FALSE)
10. Ignored
11. Ignored
12. Role (e.g. End User)
13. Ignored
14. Ignored
15. Certificate type

Any remaining columns are ignored.

AllDepts.csv should not include a header row.

### AD.csv
Dump of Active Directory users in CSV format with
the following columns:
1. Primary SMTP address (email attribute)
2. Department Acronym (ignored)
3. Domain (ingnored)

### AllVIPs.csv
A concatenated list of all VIP certificates proviced
by ICM-mananaged departments. In CSV format with the
following columns:
1. Scheduled certificate update date (YYYY-MM-DD)
2. Distinguished name

AllVIPs.csv should not include a header row.

### AllPilot.txt
A list of certificate distinguished names (one per line) to be exluded
from the output files. Note that certificates that already
support OCSP are automatically included, so this file
onnly needs to include pilot users who will update to
OCSP after AllDepts.csv is produced.

## Preprocessing requirement
All files originating from Windows (Excel) must have their
line endings converted to Unix format using dos2unix
before processing.

## Outputs
All output is written to /tmp/icmdata.

### AD.csv
Cleaned up Active Directory data, i.e. excluding
invalid and non-GC email addresses.

### DEPT-filtered.csv
File of certificates that pass the filtering criteria, i.e.
excluding device, external (consultant) and
expired certificates.

### DEPT-matching.csv
Filtered certificates that match an email address in
Active Directory.

### DEPT-unmatched.csv
Filtered certificates that do not match an email
address in Active Directory

### DEPT-final.csv
Matching certificates, excluding VIP and pilot users.

### KMC/DEPT-DayNN.txt
List of certificates to be updated for the named
ICM-managed department on day NN of their schedule.

### KMC/VIP-MMM-DD.txt
List of VIP certificates to be updated on MMM-DD where MMM is
the month abbreviation (Jan, Feb, ...).

