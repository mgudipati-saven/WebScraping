/* Create the schema for our tables */
create table CCASSHoldingsDaily(issueCode int, issueName text, holding bigint, holdingValue bigint, stake decimal(16,2), holdingDate date);
	