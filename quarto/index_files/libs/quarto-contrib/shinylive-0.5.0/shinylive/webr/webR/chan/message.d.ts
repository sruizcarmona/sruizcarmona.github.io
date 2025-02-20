/**
 * WebR communication channel messaging and request types.
 * @module Message
 */
import { UUID } from './task-common';
/** A webR communication channel message. */
export interface Message {
    type: string;
    data?: any;
}
/** A webR communication channel request. */
export interface Request {
    type: 'request';
    data: {
        uuid: UUID;
        msg: Message;
    };
}
/** A webR communication channel response. */
export interface Response {
    type: 'response';
    data: {
        uuid: UUID;
        resp: unknown;
    };
}
/** @internal */
export declare function newRequest(msg: Message, transferables?: [Transferable]): Request;
/** @internal */
export declare function newResponse(uuid: UUID, resp: unknown, transferables?: [Transferable]): Response;
/** A webR communication channel sync-request.
 * @internal
 */
export interface SyncRequest {
    type: 'sync-request';
    data: {
        msg: Message;
        reqData: SyncRequestData;
    };
}
/** Transfer data required when using sync-request with SharedArrayBuffer.
 * @internal */
export interface SyncRequestData {
    taskId?: number;
    sizeBuffer: Int32Array;
    signalBuffer: Int32Array;
    dataBuffer: Uint8Array;
}
/** @internal */
export declare function newSyncRequest(msg: Message, data: SyncRequestData): SyncRequest;
