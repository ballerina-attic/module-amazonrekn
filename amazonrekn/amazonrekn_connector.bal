// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/internal;
import ballerina/time;
import ballerina/http;
import ballerina/crypto;
import ballerina/system;
import ballerina/encoding;

import wso2/amazoncommons;

# Object to initialize the connection with Amazon Rekognition Service.
#
# + accessKey - The Amazon API access key
# + secretKey - The Amazon API secret key
public type Client client object {

    http:Client clientEp;
    string accessKey;
    string secretKey;
    string region;

    public function __init(Configuration config) {
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
        self.region = config.region;
        self.clientEp = new("https://" + REKN_SERVICE_NAME + "." + self.region + "." + amazoncommons:AMAZON_HOST);
    }

    function execReknAction(string accessKey, string secretKey, string region, string action,
                            string payload) returns string|error;

    # Detects the text in the given image data or the S3 object.
    # + input - The input as an image byte[] or an `S3Object` record
    # + return - The detected text or an `error` object if the operation failed
    public remote function detectText(amazoncommons:S3Object|byte[] input) returns string|error;

    # Detects the labels in the given image data or the S3 object.
    # + input - The input as an image byte[] or an `S3Object` record
    # + maxLabels - The maximum number of labels to be returned, -1 is unlimited
    # + minConfidence - The minimum confidence level of the detection to return results
    # + return - The detected labels as an `Label[]` or an `error` object if the operation failed
    public remote function detectLabels(amazoncommons:S3Object|byte[] input, int maxLabels = -1, 
                                        int minConfidence = 55) returns Label[]|error;

};

function Client.execReknAction(string accessKey, string secretKey, string region, string action,
                               string payload) returns string|error {
    string host = REKN_SERVICE_NAME + "." + region + "." + amazoncommons:AMAZON_HOST;
    string amzTarget = "RekognitionService." + action;
    time:Time time = time:toTimeZone(time:currentTime(), "GMT");
    string amzdate = amazoncommons:generateAmzdate(time);
    string datestamp = amazoncommons:generateDatestamp(time);

    map<string> headers = {};
    headers["Content-Type"] = REKN_CONTENT_TYPE;
    headers["Host"] = host;
    headers["X-Amz-Date"] = amzdate;
    headers["X-Amz-Target"] = amzTarget;

    amazoncommons:populateAuthorizationHeaders(accessKey, secretKey, region, REKN_SERVICE_NAME, payload, "/", 
                                               "", headers, "POST", amzdate, datestamp);

    http:Request request = new;
    request.setTextPayload(payload);
    foreach var (k,v) in headers {
        request.setHeader(k, v);
    }
    var httpResponse = self.clientEp->post("/", request);
    if (httpResponse is http:Response) {
        return httpResponse.getPayloadAsString();
    } else {
        return httpResponse;
    } 
}

function createImageJson(amazoncommons:S3Object|byte[] input) returns json {
    json payload;
    if (input is byte[]) {
        payload = { Image: { Bytes: encoding:encodeBase64(input) } };
    } else {
        payload = { Image: { S3Object: { Bucket: input.bucket, Name: input.name } } };
    }
    return payload;
}

function parseJson(string data) returns json|error {
    io:StringReader reader = new(data);
    return reader.readJson();
}

public remote function Client.detectText(amazoncommons:S3Object|byte[] input) returns string|error {
    json payload = createImageJson(input);
    string result = check self.execReknAction(self.accessKey, self.secretKey, self.region, "DetectText",
                                              check string.convert(payload));
    json jr = check parseJson(result);
    string strResult = "";
    int dcount = jr.TextDetections.length();
    int i = 0;
    int lineCount = 0;
    while (i < dcount) {
        if (jr.TextDetections[i].Type == "LINE") {
            if (lineCount > 0) {
                strResult = strResult + "\n";
            }
            strResult = strResult + <string> jr.TextDetections[i].DetectedText;
            lineCount = lineCount + 1;
        }
        i = i + 1;
    }
    return strResult;
}

public remote function Client.detectLabels(amazoncommons:S3Object|byte[] input, int maxLabels = -1, 
                                           int minConfidence = 55) returns Label[]|error {
    json payload = createImageJson(input);
    if (maxLabels != -1) {
        payload.MaxLabels = maxLabels;
    }
    payload.MinConfidence = minConfidence;
    string result = check self.execReknAction(self.accessKey, self.secretKey, self.region, "DetectLabels",
                                              check string.convert(payload));
    json jr = check parseJson(result);
    int dcount = jr.Labels.length();
    int i = 0;
    Label[] labels = [];
    while (i < dcount) {
        Label label = { name: <string> jr.Labels[i].Name, confidence: <int> jr.Labels[i].Confidence };
        labels[i] = label;
        i = i + 1;
    }
    return labels;
}

# Azure Blob Service configuration.
# + accessKey - The Amazon access key
# + secretKey - The Amazon secret key
# + region    - The Amazon region
public type Configuration record {
    string accessKey;
    string secretKey;
    string region = amazoncommons:DEFAULT_REGION;
};


