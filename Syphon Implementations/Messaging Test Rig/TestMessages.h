//
//  TestMessages.h
//  Server
//
//  Created by Tom Butterworth on 07/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//  Message                             // Payload
enum {                                  //
    TestMessageDate,                    // a NSDate representing the time the message was sent
    TestMessageAwaitingConnection,      // A NSString which is the name of the waiting connection
    TestMessageTestingConnection,       // nil
    TestMessageAwaitingConnectionCount, // A NSString which is the name of the waiting connection
    TestMessageConnectionCount          // A NSNumber representing the number of TestMessageAwaitingConnection messages the server has seen.
};