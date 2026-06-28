#!/usr/bin/env dotnet-script
using Microsoft.Data.Sqlite;

var dbPath = @"C:\Users\Jack Russell\AppData\Local\GateTrack\attendance.db";
var connStr = $"Data Source={dbPath}";

using var conn = new SqliteConnection(connStr);
conn.Open();

// List all students
Console.WriteLine("=== ALL STUDENTS ===");
using (var cmd = conn.CreateCommand()) {
    cmd.CommandText = "SELECT Id, StudentNo, FirstName, LastName, IsDeleted FROM Students ORDER BY Id";
    using var r = cmd.ExecuteReader();
    while (r.Read()) {
        Console.WriteLine($"ID:{r["Id"]} LRN:{r["StudentNo"]} Name:{r["LastName"]},{r["FirstName"]} Deleted:{r["IsDeleted"]}");
    }
}
