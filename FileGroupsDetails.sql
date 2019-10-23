SELECT object_name(i.[object_id]) as Name_of_Object,
i.name as Index_Name,
i.type_desc as Index_Type,
f.name as Name_of_Filegroup,
a.type as Object_Type,
f.type,
f.type_desc
FROM sys.filegroups as f 
INNER JOIN sys.indexes as i 
 ON f.data_space_id = i.data_space_id
INNER JOIN sys.all_objects as a 
 ON i.object_id = a.object_id
WHERE a.type ='U' -- User defined tables only