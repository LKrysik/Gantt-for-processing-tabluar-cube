# H1 Gantt for processing tabluar cube for on-premise services
 Creates gantt based on extended events for processing tabular cube

## H2 What for
If you want find bottlenecks in processing tabular cube with this simple code you can analyse progress of table processing inside tabluar cube 

## H2 How use this simple code
1. Open SSMS 
2. Connect to your tabluar instance
3. Open and execute XMLA exev_tabular_processing_session.xmla (provide path where XEL file will be stored)
4. Star processing your tabular cube (full, table)
5. In SSMS open file "xel2gantt.sql" (provide path where XEL file has been stored)
6. Execute sql file -> have fun with gantt graph
