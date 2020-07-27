# Gantt for processing tabluar cube
 Creates gantt based on extended events for processing tabular cube


1. Open SSMS 
2. Connect to your tabluar instance
3. Open and execute XMLA exev_tabular_processing_session.xmla (provide path where XEL file will be stored)
4. Star processing your tabular cube
5. In SSMS open file "xel2gantt.sql" (provide path where XEL file has been stored)
6. Execute sql file -> have fun with gantt graph
