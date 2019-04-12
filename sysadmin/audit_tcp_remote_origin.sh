#!/bin/bash
# Useful if you feel you’re getting DDOS, flood, or other attacks:

netstat -an | grep tcp | awk '{print $5}'|sed 's/::ffff://'|cut -f1 -d':'| sort | uniq -c | sort -n -r