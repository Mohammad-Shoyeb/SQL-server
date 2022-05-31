USE diagonsticscenter
GO
/*
 * Sample data
 * */
INSERT INTO testtypes (typeid, typename) VALUES (1, 'Blood')
INSERT INTO testtypes (typeid, typename) VALUES (2, 'Urine')
INSERT INTO testtypes (typeid, typename) VALUES (3, 'ECG')
GO
SELECT * FROM testtypes
GO
INSERT INTO tests (testid, testname, fee, typeid)
VALUES 
(1, 'CBC', 670.00, 1),
(2, 'BMP', 1400, 1),
(3, 'CMP', 2700.00, 1),
(4, 'Lipid panel (LDL)', 1700.00, 1),
(5, 'Lipid panel (HDL)', 3500.00, 1)
GO 
INSERT INTO tests (testid, testname, fee, typeid)
VALUES 
(6, 'RBC', 150.00, 2),
(7, 'WBC', 150, 2),
(8, 'Creatinine', 700.00, 2)
GO 
INSERT INTO tests (testid, testname, fee, typeid)
VALUES 
(9, 'ECG (R)', 450.00, 3),
(10, 'ECG (Ex)', 450, 3),
(11, 'ECG (Ambulatory)', 600.00, 3)
GO 
SELECT * FROM tests
GO
/*
 * Test procedures
 */
 EXEC spinserttype 4, 'X-Ray'
--EXEC spinserttype 13, 'X-Ray' --fails, name duplicate
GO
SELECT * FROM testtypes
GO
EXEC spupdatetype 4, 'X-Ray1'
GO
SELECT * FROM testtypes
GO
EXEC spupdatetype 4, 'X-Ray'
GO
SELECT * FROM testtypes
GO
INSERT INTO testtypes VALUES (5, 'Test')
GO
SELECT * FROM testtypes
GO
EXEC spdeletetype 5
GO
SELECT * FROM testtypes
GO
EXEC spinserttest 12, 'Sugar (R)', 100, 1
EXEC spinserttest 13, 'Sugar (BF)', 100, 1
EXEC spinserttest 14, 'Sugar (AF)', 100, 1
GO
EXEC spupdatetest 12, 'Sugar (R)', 120, 1
GO
EXEC spdeletetest 14
GO
SELECT * FROM tests
GO
EXEC spinserttestentry 1, 'Abul kalam', '1981-07-12', '01967777766'
EXEC spinserttestentry 2, 'Azad Islam', '1981-07-12', '01767222553', '2022-03-01', '2022-03-06'
GO
SELECT * FROM testentries
GO
EXEC spupdatetestentry 2, 'Tamim Iqbal', '1981-07-12', '01867444432', '2022-03-01', '2022-03-06', 1
GO
SELECT * FROM testentries
GO
EXEC spinsertentrytest 1, 2
EXEC spinsertentrytest 1, 3
EXEC spinsertentrytest 2, 11
EXEC spinsertentrytest 2, 3
GO
SELECT * FROM entrytests
GO
/*
 * Query
 */
--all data
SELECT tt.typename, t.testname, t.fee, te.patientname, te.dateofbirth, te.mobileno, te.testdate, te.duedate, te.[status]
FROM testtypes tt
INNER JOIN tests t ON tt.typeid = t.typeid
INNER JOIN entrytests et ON t.testid = et.testid
INNER JOIN testentries te ON te.entryid = et.entryid
GO
--due entries
SELECT te.patientname, te.dateofbirth, te.mobileno, tt.typename, t.testname, t.fee, te.testdate
FROM testentries te
INNER JOIN entrytests et ON te.entryid = et.entryid
INNER JOIN tests t ON et.testid = t.testid
INNER JOIN testtypes tt ON t.typeid = tt.typeid
WHERE te.[status]=0
GO
--test wise report current month
SELECT  t.testname,  COUNT(*), SUM(t.fee)
FROM testentries te
INNER JOIN entrytests et ON te.entryid = et.entryid
INNER JOIN tests t ON et.testid = t.testid
INNER JOIN testtypes tt ON t.typeid = tt.typeid
WHERE YEAR(testdate) = YEAR(GETDATE()) AND MONTH(testdate) = MONTH(GETDATE())
GROUP BY t.testname
/*
 * Test views
 * */
SELECT * FROM vAll
GO
SELECT * FROM vDueTests
GO
SELECT * FROM vReportCurrentMonth

GO
/*
 * Test functions
 * */
SELECT * FROM fnReportsInDates('2022-03-01', '2022-03-10')
GO
SELECT * FROM fnReportInDates('2022-03-01', '2022-03-10')
GO
/*
 * Test triggers
 */
EXEC spinsertentrytest 1, 1
EXEC spinsertentrytest 1, 2 --error
GO
EXEC spupdatetest 12, 'Sugar (R)', 20, 1
GO
DELETE FROM entrytests
WHERE entryid=2 AND testid=3
GO