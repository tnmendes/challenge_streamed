# Mobile Developer recruitment challenge: Telemetry Data

The purpose of this challenge is to demonstrate how you:

  - write and structure a simple Android or iOS application,
  - parse streamed telemetry data,
  - perform background processing on a mobile platform.

Feel free to use any libraries, frameworks or dependencies you want in order
to achieve the task.

Include instructions for how to build and run your code, any tests you've
written and some text explaining what you did.

We hope that it won't take you more than a couple of hours to get your application up and running.

### Scenario

In a medical study, sensor data from various sources has to be collected by a mobile phone.
The study is at a concept stage where the feasibility of the architecture is being evaluated.

### Challenge

The remote sensor has been simulated by a continuous stream of UDP packets.
Read this data into a mobile phone application (either iOS or Android).
Calculate a moving average of the data values over the last 30 seconds and track the maximum and minimum values of the raw data.
In the UI, present the data in a way of your choosing.

### Simulated Sensor Data

The simulator needs python3 to run.

Run the UDP streaming server as follows with a port number of your choice.
```
python3 server.py PORTNUMBER
```

Make a connection from your application to the server by sending a single packet to initialise the data stream.

Once initialised, the server will generate, encode and send a datapoint every 0.1 seconds.
The data is a base64 representation of the following format:

| Byte # | data |
| --- | --- |
| 0-2 | time marker |
| 3-4 | sensor data |

#### Example
| Data | Hex representation | base64 |
| --- | --- | --- |
| 5 999 | 0x000005 0x03E7 | AAAFA+c= |

This would equate to a marker at time unit 5 and a data value of 999.

To provide a continuous data stream from a fixed sample file, time marker will reset to 0 when it reaches 79116.
