const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onCreate(async (snapshot, context) => {
        console.log('Follower Created', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        // 1) Create followed user posts ref
        const followedUserPostsRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts');

        // 2) Create following users timeline ref
        const followingUsertimelinePostsRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts');

        // 3) Get followed users posts
        const querySnapshot = await followedUserPostsRef.get();

        // 4) Add each of users posts to following user's timeline 
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                followingUsertimelinePostsRef.doc(postId).set(postData);
            }
        });





    });

exports.onDeleteFollower = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onDelete(async (snapshot, context) => {
        console.log('Follower Deleted', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const followingUsertimelinePostsRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where('ownerId', '==', userId);

        const querySnapshot = await followingUsertimelinePostsRef.get();

        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });

    });

exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onCreate(async (snapshot, context) => {
        console.log('Post Created', snapshot.id);
        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1) Get all the followers of the user who made the post 
        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();
        // 2) add new posts to each followers timeline

        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated);

        });

    });

exports.onUpdatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (change, context) => {
        console.log('Post Updated', change.after.id);

        const postUpdated = change.after.data();
        const postId = context.params.postId;
        const userId = context.params.userId;

        // 1) Get all the followers of the user who made the post 
        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        // 2) add new posts to each followers timeline

        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.update(postUpdated);
                    }
                });
        });

    });
exports.onDeletePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onDelete(async (snapshot, context) => {
        console.log('Post Deleted', snapshot.id);
        const postId = context.params.postId;
        const userId = context.params.userId;

        // 1) Get all the followers of the user who made the post 
        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        // 2) delete  posts from each followers timeline

        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.delete();
                    }
                });
        });

    });

exports.onCreateActivityFeedItem = functions.firestore
    .document('/feed/{userId}/feedItems/{activityFeedItem}')
    .onCreate(async (snapshot, context) => {
        console.log('Activity Feed Item Created', snapshot.data());

        // 1) Get user connected to the feed, 
        //send notification if they have token
        const userId = context.params.userId;

        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        // 2) Once we have user check if they have notification item
        const androidNotificationToken = doc.data().androidNotificationToken;

        const createdActivityFeedItem = snapshot.data();
        if (androidNotificationToken) {
            // send notification
            sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else {
            console.log('User have no token, cant send notification');
        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;
            let title;
            // switch bod   y value base on notification item (like, comment or follow)
            switch (activityFeedItem.type) {
                case 'comment':
                    body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
                    title = 'New Comment';
                    break;
                case 'like':
                    body = `${activityFeedItem.username} liked your post.`;
                    title = 'New like';
                    break;
                case 'follow':
                    body = `${activityFeedItem.username} followed you.`;
                    title = 'New Follower';
                    break;
                default:
                    break;
            }

            // 4) create message for push notification
            var message = {
                notification: {
                    body: body,
                    title: title,

                },
                token: androidNotificationToken,
                data: { recipient: userId },
            };

            // 5) send message with admin.messaging
            admin
                .messaging()
                .send(message)
                .then((response) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message:', response);
                })
                .catch((error) => {
                    console.log('Error sending message:', error);
                });

        }
    });

exports.onCreateUser = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onCreate(async (snapshot, context) => {
        console.log('Follower Created', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        // 1) Create followed user posts ref
        const followedUserPostsRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts');

        // 2) Create following users timeline ref
        const followingUsertimelinePostsRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts');

        // 3) Get followed users posts
        const querySnapshot = await followedUserPostsRef.get();

        // 4) Add each of users posts to following user's timeline 
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                followingUsertimelinePostsRef.doc(postId).set(postData);
            }
        });





    });