#!/usr/bin/env bash

curl -v -L -X POST "http://localhost/wps3/processes/DeployProcess/jobs" -H  \
  "accept: application/json" -H  "Prefer: respond-async" -H  "Content-Type: application/json" -d@${1} \
	-H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsImtpZCI6IlJTQTEifQ.eyJhY3RpdmUiOnRydWUsImV4cCI6MTU5MzUxNTU2NSwiaWF0IjoxNTkzNTExOTY1LCJuYmYiOm51bGwsInBlcm1pc3Npb25zIjpbeyJyZXNvdXJjZV9pZCI6ImI3Y2FkZTVjLTM3MmYtNGM4Ny1iZTgyLWE3OTU2NDk4ZTcyOSIsInJlc291cmNlX3Njb3BlcyI6WyJBdXRoZW50aWNhdGVkIiwib3BlbmlkIl0sImV4cCI6MTU5MzUxNTU2NCwicGFyYW1zIjpudWxsfV0sImNsaWVudF9pZCI6IjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSIsInN1YiI6bnVsbCwiYXVkIjoiNjFjZTI4ZDUtYWExNi00ZGRjLTg0MmYtZmNjMTU4ZDMxNWZhIiwiaXNzIjpudWxsLCJqdGkiOm51bGwsInBjdF9jbGFpbXMiOnsiYXVkIjpbIjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSJdLCJzdWIiOlsiZWIzMTQyMWUtMGEyZS00OTBmLWJiYWYtMDk3MWE0ZTliNzhhIl0sInVzZXJfbmFtZSI6WyJyZGlyaWVuem8iXSwiaXNzIjpbImh0dHBzOi8vZW9lcGNhLWRldi5kZWltb3Mtc3BhY2UuY29tIl0sImV4cCI6WyIxNTkzNTE1NTY0Il0sImlhdCI6WyIxNTkzNTExOTY0Il0sIm94T3BlbklEQ29ubmVjdFZlcnNpb24iOlsib3BlbmlkY29ubmVjdC0xLjAiXX19.A8a-SL0mqmQ-tP0lGQN6QIKAcT4l2LcHoIF5avaD4Yk"

