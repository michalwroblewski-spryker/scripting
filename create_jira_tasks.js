// This code sample uses the 'node-fetch' library:
// https://www.npmjs.com/package/node-fetch
//const fetch = require('node-fetch');
import fetch from 'node-fetch';
import fs from 'fs';
import csv from 'csv-parser';
import config from './config.js';
import minimist from 'minimist';

const args = minimist(process.argv.slice(2));
// initial delay required due to AP limits
let delay = 1;

async function processEnvFile(filePath) {
    fs.createReadStream(filePath)
        .pipe(csv())
        .on('data', (row) => {
            delay+=config.timeout;
            processEnv(row, delay);
        });
}

// process env with a delay one
async function processEnv(row, timeout) {    
    setTimeout(() => { createIssue(row.env_name, row.env_version, timeout)}, timeout);
}

function createIssue(envName, envVer) {
    //console.log(`Process environment ${envName} current version ${envVer}`);
    const bodyData = `{   
        "fields": {
            "summary": "${config.summary} ${envName} current: ${envVer}",
            "project": {
                "key": "${config.project}"
            },
            "parent": {
                "key": "${args.parent}"
            },
            "issuetype": {
                "name": "Sub-Task"
            },   
            "description": {
                "type": "doc",
                "version": 1,
                "content": [
                {
                    "type": "paragraph",
                    "content": [
                    {
                        "text": "${config.description}",
                        "type": "text"
                    }
                    ]
                }
                ]
            },
            "labels": [
                "${config.label}"
            ]  
        }
        }`;

    fetch(config.jiraURL, {
    method: 'POST',
    headers: {
        'Authorization': `Basic ${Buffer.from(
        config.user + ":" + config.api_key
        ).toString('base64')}`,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    },
    body: bodyData
    })
    .then(response => {
        if (response.status === 201)
            return response.json();
        else   
            throw new Error(response.statusText);
    })    
    .then(response => 
        console.log(`${envName}; ${envVer}; https://spryker.atlassian.net/browse/${response.key}`))
    .catch(err => console.error(err));        
}

processEnvFile(args.envFile);
