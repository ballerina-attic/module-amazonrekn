Connects to Amazon Rekognition service.

# Module Overview

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.990.3                    

## Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/amazonrekn;
import wso2/amazoncommons;

amazonrekn:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    secretKey: config:getAsString("SECRET_KEY")
};

amazonrekn:Client reknClient = new(config);

public function main() {
    byte[] data = readFile("input.jpeg");
    var result1 = reknClient->detectLabels(untaint data);
    io:println(result1);

    amazoncommons:S3Object s3obj = { bucket: "mybucket", name: "input.jpeg" };
    var result2 = reknClient->detectText(s3obj);
    io:println(result2);
}

function readFile(string path) returns byte[] {
    io:ReadableByteChannel ch = io:openReadableFile(path);
    byte[] output = [];
    int i = 0;
    while (true) {
        (byte[], int) (buff, n) = check ch.read(1000);
        if (n == 0) {
            break;
        }
        foreach byte b in buff {
            output[i] = b;
            i += 1;
        }
    }
    _ = ch.close();
    return output;
}
```
