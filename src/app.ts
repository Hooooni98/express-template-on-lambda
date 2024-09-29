import { Context, APIGatewayEvent } from 'aws-lambda';
import * as serverless from 'aws-serverless-express';
import express, { Request, Response } from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import * as dotenv from 'dotenv';

dotenv.config();
const app = express();

app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json())
app.use(express.json());

app.get('/hello', (req: Request, res: Response) => {
    console.log('hello')
    res.send({'message': 'hello'})
})

const server = serverless.createServer(app)


export const handler = (event: APIGatewayEvent, context: Context) => {
    serverless.proxy(server, event, context)
}

if (process.env.NODE_ENV == 'local') {
    const startServer = async () => {
        app.listen(80);
    }
    startServer();
}



