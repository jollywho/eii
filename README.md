Convert standard sql queries
`SELECT id,name FROM master WHERE author like '%miyazaki%'`
       ^    ^    ^    ^    ^
       |    |    |    |    |
       v    v    v    v    v
`eii -s -t master -c id name -f author -v miyazaki`
