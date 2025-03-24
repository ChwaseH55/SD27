import React, { useState, useEffect, useRef } from 'react';
import { ref, push, onValue, off, query, orderByChild, get, update, remove, set } from 'firebase/database';
import { getStorage, ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage';
import { useSelector } from 'react-redux';
import { database } from '../firebase';
import { api } from '../config';
import UserAvatar from './UserAvatar';

const Chat = () => {
    const [messages, setMessages] = useState([]);
    const [newMessage, setNewMessage] = useState('');
    const [activeChat, setActiveChat] = useState(null);
    const [chats, setChats] = useState([]);
    const [showUserModal, setShowUserModal] = useState(false);
    const [availableUsers, setAvailableUsers] = useState([]);
    const [selectedUsers, setSelectedUsers] = useState([]);
    const [isGroupChat, setIsGroupChat] = useState(false);
    const [groupName, setGroupName] = useState('');
    const [editingMessage, setEditingMessage] = useState(null);
    const [replyingTo, setReplyingTo] = useState(null);
    const [showAddUsersModal, setShowAddUsersModal] = useState(false);
    const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
    const [uploadingImage, setUploadingImage] = useState(false);
    const messagesEndRef = useRef(null);
    const fileInputRef = useRef(null);
    const currentUser = useSelector(state => state.user.user);
    const storage = getStorage();

    // Scroll to bottom of messages
    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    // Load user's chats
    useEffect(() => {
        if (!currentUser) return;

        const chatsRef = ref(database, 'chats');
        // Convert ID to string to match Firebase format
        const userId = currentUser.id.toString();
        const userChatsQuery = query(chatsRef);

        onValue(userChatsQuery, async (snapshot) => {
            const chatsData = snapshot.val();
            if (chatsData) {
                const chatsArray = Object.entries(chatsData)
                    .map(([id, chat]) => ({
                        id,
                        ...chat
                    }))
                    .filter(chat => chat.participants && chat.participants[userId] === true);
                
                // Create a Set of unique user IDs we need to fetch
                const userIdsToFetch = new Set();
                chatsArray.forEach(chat => {
                    if (chat.type === 'direct') {
                        const otherUserId = Object.keys(chat.participants)
                            .find(id => id !== userId);
                        if (otherUserId) {
                            userIdsToFetch.add(otherUserId);
                        }
                    }
                });

                // Fetch all users at once
                try {
                    const response = await api.get('/users');
                    const allUsers = response.data.reduce((acc, user) => {
                        acc[user.id] = user;
                        return acc;
                    }, {});

                    // Map chats with user details
                    const chatsWithDetails = chatsArray.map(chat => {
                        if (chat.type === 'direct') {
                            const otherUserId = Object.keys(chat.participants)
                                .find(id => id !== userId);
                            
                            if (!otherUserId) return chat;

                            const userData = allUsers[otherUserId];
                            if (userData) {
                                return {
                                    ...chat,
                                    otherUser: {
                                        id: userData.id,
                                        username: userData.username || 'Unknown',
                                        firstname: userData.firstname || userData.firstName || 'Unknown',
                                        lastname: userData.lastname || userData.lastName || 'User'
                                    }
                                };
                            }
                        }
                        return chat;
                    });

                    setChats(chatsWithDetails);
                } catch (error) {
                    console.error('Error fetching users:', error);
                    // Set chats with placeholder data for errors
                    const chatsWithPlaceholders = chatsArray.map(chat => {
                        if (chat.type === 'direct') {
                            const otherUserId = Object.keys(chat.participants)
                                .find(id => id !== userId);
                            return {
                                ...chat,
                                otherUser: {
                                    id: otherUserId,
                                    username: 'Unknown User',
                                    firstname: 'Unknown',
                                    lastname: 'User'
                                }
                            };
                        }
                        return chat;
                    });
                    setChats(chatsWithPlaceholders);
                }
            } else {
                setChats([]);
            }
        });

        return () => {
            off(userChatsQuery);
        };
    }, [currentUser]);

    // Load messages for active chat
    useEffect(() => {
        if (!activeChat) return;

        const messagesRef = ref(database, `messages/${activeChat.id}`);
        const messagesQuery = query(messagesRef, orderByChild('timestamp'));

        onValue(messagesQuery, (snapshot) => {
            const messagesData = snapshot.val();
            if (messagesData) {
                const messagesArray = Object.entries(messagesData).map(([id, message]) => ({
                    id,
                    ...message
                }));
                setMessages(messagesArray);
            }
        });

        return () => {
            off(messagesQuery);
        };
    }, [activeChat]);

    // Fetch available users for chat
    const fetchAvailableUsers = async () => {
        try {
            const response = await api.get('/users');
            const usersData = response.data;
            
            if (Array.isArray(usersData)) {
                // Filter out current user and users already in direct messages
                const existingDirectMessageUsers = new Set();
                chats.forEach(chat => {
                    if (chat.type === 'direct') {
                        Object.keys(chat.participants).forEach(userId => {
                            if (userId !== currentUser.id.toString()) {
                                existingDirectMessageUsers.add(userId);
                            }
                        });
                    }
                });

                const availableUsersArray = usersData
                    .filter(user => 
                        user.id !== currentUser.id && 
                        (isGroupChat || !existingDirectMessageUsers.has(user.id.toString()))
                    )
                    .map(user => ({
                        id: user.id.toString(),
                        username: user.username,
                        firstname: user.firstname || user.firstName,
                        lastname: user.lastname || user.lastName
                    }));
                
                setAvailableUsers(availableUsersArray);
            } else {
                console.error('Invalid users data format:', usersData);
                setAvailableUsers([]);
            }
        } catch (error) {
            console.error('Error fetching users:', error);
            setAvailableUsers([]);
        }
    };

    const openNewChatModal = (isGroup) => {
        setIsGroupChat(isGroup);
        setSelectedUsers([]);
        setGroupName('');
        fetchAvailableUsers();
        setShowUserModal(true);
    };

    const toggleUserSelection = (user) => {
        if (selectedUsers.find(u => u.id === user.id)) {
            setSelectedUsers(selectedUsers.filter(u => u.id !== user.id));
        } else {
            if (!isGroupChat && selectedUsers.length > 0) return; // Only one user for direct messages
            setSelectedUsers([...selectedUsers, user]);
        }
    };

    const createNewChat = async () => {
        if (!currentUser || selectedUsers.length === 0) return;
        if (isGroupChat && !groupName.trim()) return;

        const participants = {
            [currentUser.id.toString()]: true,
            ...Object.fromEntries(selectedUsers.map(user => [user.id.toString(), true]))
        };

        const chatData = {
            type: isGroupChat ? 'group' : 'direct',
            createdBy: currentUser.id.toString(),
            createdAt: Date.now(),
            participants,
            ...(isGroupChat && { name: groupName })
        };

        try {
            await push(ref(database, 'chats'), chatData);
            setShowUserModal(false);
            setSelectedUsers([]);
            setGroupName('');
        } catch (error) {
            console.error('Error creating chat:', error);
        }
    };

    const addUsersToGroup = async () => {
        if (!activeChat || !selectedUsers.length) return;

        const updates = {};
        selectedUsers.forEach(user => {
            updates[`chats/${activeChat.id}/participants/${user.id}`] = true;
        });

        try {
            await update(ref(database), updates);
            setShowAddUsersModal(false);
            setSelectedUsers([]);
        } catch (error) {
            console.error('Error adding users to group:', error);
        }
    };

    const handleMessageAction = async (message, action) => {
        if (!activeChat || !currentUser) return;

        switch (action) {
            case 'edit':
                setEditingMessage(message);
                setNewMessage(message.text);
                break;

            case 'delete':
                try {
                    await remove(ref(database, `messages/${activeChat.id}/${message.id}`));
                } catch (error) {
                    console.error('Error deleting message:', error);
                }
                break;

            case 'like':
                const likePath = `messages/${activeChat.id}/${message.id}/likes/${currentUser.id}`;
                const likeRef = ref(database, likePath);
                try {
                    const snapshot = await get(likeRef);
                    if (snapshot.exists()) {
                        await remove(likeRef);
                    } else {
                        await set(likeRef, true);
                    }
                } catch (error) {
                    console.error('Error toggling like:', error);
                }
                break;

            case 'reply':
                setReplyingTo(message);
                break;

            default:
                break;
        }
    };

    const sendMessage = async (e) => {
        e.preventDefault();
        if (!newMessage.trim() || !activeChat || !currentUser) return;

        const messageData = {
            text: newMessage,
            senderId: currentUser.id.toString(),
            senderName: currentUser.username,
            timestamp: Date.now()
        };

        // Only add replyTo if we have all the required data
        if (replyingTo && replyingTo.text && replyingTo.senderName) {
            messageData.replyTo = {
                id: replyingTo.id,
                text: replyingTo.text,
                senderName: replyingTo.senderName
            };
        }

        try {
            if (editingMessage) {
                await update(ref(database, `messages/${activeChat.id}/${editingMessage.id}`), {
                    text: newMessage,
                    edited: true,
                    editedAt: Date.now()
                });
                setEditingMessage(null);
            } else {
                await push(ref(database, `messages/${activeChat.id}`), messageData);
            }
            setNewMessage('');
            setReplyingTo(null);
        } catch (error) {
            console.error('Error sending/editing message:', error);
        }
    };

    const deleteChat = async () => {
        if (!activeChat || !currentUser) return;
        
        try {
            // Delete all messages in the chat
            await remove(ref(database, `messages/${activeChat.id}`));
            // Delete the chat itself
            await remove(ref(database, `chats/${activeChat.id}`));
            setActiveChat(null);
            setShowDeleteConfirm(false);
        } catch (error) {
            console.error('Error deleting chat:', error);
        }
    };

    const handleImageUpload = async (e) => {
        const file = e.target.files[0];
        if (!file || !activeChat) return;

        try {
            setUploadingImage(true);
            
            // Create a storage reference
            const imageRef = storageRef(storage, `chat_images/${activeChat.id}/${Date.now()}_${file.name}`);
            
            // Upload the file
            await uploadBytes(imageRef, file);
            
            // Get the download URL
            const downloadURL = await getDownloadURL(imageRef);
            
            // Create message with image
            const messageData = {
                text: '',
                senderId: currentUser.id.toString(),
                senderName: currentUser.username,
                timestamp: Date.now(),
                image: downloadURL
            };
            
            await push(ref(database, `messages/${activeChat.id}`), messageData);
            setUploadingImage(false);
        } catch (error) {
            console.error('Error uploading image:', error);
            setUploadingImage(false);
        }
    };

    const ChatListItem = ({ chat, isActive, onClick, currentUser }) => {
        const otherUser = chat.isGroupChat 
            ? null 
            : chat.participants.find(p => p.id.toString() !== currentUser.id.toString());

        return (
            <div
                className={`flex items-center p-3 cursor-pointer hover:bg-gray-100 ${
                    isActive ? 'bg-gray-100' : ''
                }`}
                onClick={onClick}
            >
                {chat.isGroupChat ? (
                    <div className="flex items-center">
                        <div className="w-10 h-10 bg-yellow-500 rounded-full flex items-center justify-center text-white font-semibold">
                            {chat.name?.charAt(0) || 'G'}
                        </div>
                        <span className="ml-3 font-medium">{chat.name || 'Group Chat'}</span>
                    </div>
                ) : (
                    <div className="flex items-center">
                        <UserAvatar user={otherUser} size="sm" />
                        <span className="ml-3 font-medium">
                            {otherUser?.firstname} {otherUser?.lastname}
                        </span>
                    </div>
                )}
            </div>
        );
    };

    const Message = ({ message, currentUser, onReply, onEdit, onDelete }) => {
        const isOwnMessage = message.senderId === currentUser.id.toString();

        return (
            <div className={`flex items-start mb-4 ${isOwnMessage ? 'flex-row-reverse' : ''}`}>
                <UserAvatar 
                    user={{
                        id: message.senderId,
                        firstname: message.senderName?.split(' ')[0] || '',
                        lastname: message.senderName?.split(' ')[1] || '',
                        profilePicture: message.senderProfilePicture
                    }} 
                    size="sm" 
                />
                <div className={`mx-2 ${isOwnMessage ? 'text-right' : ''}`}>
                    <div className="flex items-center mb-1">
                        <span className="text-sm text-gray-600">{message.senderName}</span>
                        <span className="text-xs text-gray-400 ml-2">
                            {new Date(message.timestamp).toLocaleTimeString()}
                        </span>
                    </div>
                    {message.replyTo && (
                        <div className="text-sm text-gray-500 bg-gray-100 p-2 rounded mb-1">
                            ↪ {message.replyTo.text}
                        </div>
                    )}
                    <div className={`p-3 rounded-lg ${
                        isOwnMessage ? 'bg-blue-500 text-white' : 'bg-gray-200'
                    }`}>
                        {message.text}
                        {message.image && (
                            <img 
                                src={message.image} 
                                alt="Shared" 
                                className="mt-2 max-w-xs rounded"
                            />
                        )}
                        <div className="flex items-center justify-end gap-2 mt-1">
                            <button 
                                onClick={() => onReply(message)}
                                className="text-sm text-gray-500"
                            >
                                ↩ Reply
                            </button>
                            {isOwnMessage && (
                                <>
                                    <button 
                                        onClick={() => onEdit(message)}
                                        className="text-sm text-gray-500"
                                    >
                                        ✎ Edit
                                    </button>
                                    <button 
                                        onClick={() => onDelete(message)}
                                        className="text-sm text-gray-500"
                                    >
                                        🗑 Delete
                                    </button>
                                </>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        );
    };

    return (
        <div className="flex h-screen bg-gray-100 pt-16"> {/* Added pt-16 to account for fixed navbar */}
            {/* Sidebar with chat list */}
            <div className="w-1/4 bg-white border-r">
                <div className="p-4 border-b">
                    <button 
                        onClick={() => openNewChatModal(false)}
                        className="w-full bg-blue-500 text-white p-2 rounded mb-2"
                    >
                        New Direct Message
                    </button>
                    <button 
                        onClick={() => openNewChatModal(true)}
                        className="w-full bg-green-500 text-white p-2 rounded"
                    >
                        New Group Chat
                    </button>
                </div>
                <div className="overflow-y-auto">
                    {chats.map(chat => (
                        <ChatListItem
                            key={chat.id}
                            chat={chat}
                            isActive={activeChat?.id === chat.id}
                            onClick={() => setActiveChat(chat)}
                            currentUser={currentUser}
                        />
                    ))}
                </div>
            </div>

            {/* Main chat area */}
            <div className="flex-1 flex flex-col">
                {activeChat ? (
                    <>
                        {/* Chat header */}
                        <div className="p-4 border-b bg-white flex justify-between items-center">
                            <div>
                                <h2 className="text-xl font-semibold">
                                    {activeChat.type === 'group' 
                                        ? (activeChat.name || 'Group Chat')
                                        : (activeChat.otherUser ? `${activeChat.otherUser.firstname} ${activeChat.otherUser.lastname}` : 'Loading...')}
                                </h2>
                                <p className="text-sm text-gray-500">
                                    {activeChat.type === 'group' ? 'Group Chat' : 'Direct Message'}
                                </p>
                            </div>
                            <div className="flex gap-2">
                                {activeChat.type === 'group' && (
                                    <button
                                        onClick={() => {
                                            setIsGroupChat(true);
                                            setSelectedUsers([]);
                                            fetchAvailableUsers();
                                            setShowAddUsersModal(true);
                                        }}
                                        className="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600"
                                    >
                                        Add Users
                                    </button>
                                )}
                                {activeChat.createdBy === currentUser.id.toString() && (
                                    <button
                                        onClick={() => setShowDeleteConfirm(true)}
                                        className="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600"
                                    >
                                        Delete Chat
                                    </button>
                                )}
                            </div>
                        </div>

                        {/* Messages */}
                        <div className="flex-1 overflow-y-auto p-4">
                            {messages.map(message => (
                                <Message
                                    key={message.id}
                                    message={message}
                                    currentUser={currentUser}
                                    onReply={() => handleMessageAction(message, 'reply')}
                                    onEdit={() => handleMessageAction(message, 'edit')}
                                    onDelete={() => handleMessageAction(message, 'delete')}
                                />
                            ))}
                            <div ref={messagesEndRef} />
                        </div>

                        {/* Message input */}
                        <div className="p-4 border-t bg-white">
                            {replyingTo && (
                                <div className="mb-2 p-2 bg-gray-100 rounded flex justify-between items-center">
                                    <span className="text-sm text-gray-600">
                                        Replying to {replyingTo.senderName}
                                    </span>
                                    <button 
                                        onClick={() => setReplyingTo(null)}
                                        className="text-gray-500"
                                    >
                                        ✕
                                    </button>
                                </div>
                            )}
                            <form onSubmit={sendMessage} className="flex space-x-2">
                                <input
                                    type="text"
                                    value={newMessage}
                                    onChange={(e) => setNewMessage(e.target.value)}
                                    placeholder={editingMessage ? "Edit message..." : "Type a message..."}
                                    className="flex-1 p-2 border rounded"
                                />
                                <input
                                    type="file"
                                    ref={fileInputRef}
                                    onChange={handleImageUpload}
                                    accept="image/*"
                                    className="hidden"
                                />
                                <button
                                    type="button"
                                    onClick={() => fileInputRef.current?.click()}
                                    className="bg-green-500 text-white px-4 py-2 rounded"
                                    disabled={uploadingImage}
                                >
                                    {uploadingImage ? 'Uploading...' : '📷'}
                                </button>
                                <button
                                    type="submit"
                                    className="bg-blue-500 text-white px-4 py-2 rounded"
                                >
                                    {editingMessage ? 'Save' : 'Send'}
                                </button>
                                {editingMessage && (
                                    <button
                                        type="button"
                                        onClick={() => {
                                            setEditingMessage(null);
                                            setNewMessage('');
                                        }}
                                        className="bg-gray-500 text-white px-4 py-2 rounded"
                                    >
                                        Cancel
                                    </button>
                                )}
                            </form>
                        </div>
                    </>
                ) : (
                    <div className="flex-1 flex items-center justify-center">
                        <p className="text-gray-500">Select a chat to start messaging</p>
                    </div>
                )}
            </div>

            {/* User Selection Modal */}
            {(showUserModal || showAddUsersModal) && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                    <div className="bg-white rounded-lg p-6 w-96">
                        <h2 className="text-xl font-semibold mb-4">
                            {showAddUsersModal 
                                ? 'Add Users to Group' 
                                : (isGroupChat ? 'Create Group Chat' : 'New Direct Message')}
                        </h2>
                        
                        {isGroupChat && !showAddUsersModal && (
                            <input
                                type="text"
                                value={groupName}
                                onChange={(e) => setGroupName(e.target.value)}
                                placeholder="Group Name"
                                className="w-full p-2 border rounded mb-4"
                            />
                        )}

                        <div className="max-h-60 overflow-y-auto">
                            {availableUsers.map(user => (
                                <div
                                    key={user.id}
                                    onClick={() => toggleUserSelection(user)}
                                    className={`p-2 cursor-pointer rounded ${
                                        selectedUsers.find(u => u.id === user.id)
                                            ? 'bg-blue-100'
                                            : 'hover:bg-gray-100'
                                    }`}
                                >
                                    <span className="font-semibold">{user.username}</span>
                                    <span className="text-sm text-gray-600 ml-2">
                                        {user.firstname} {user.lastname}
                                    </span>
                                </div>
                            ))}
                        </div>

                        <div className="mt-4 flex justify-end space-x-2">
                            <button
                                onClick={() => {
                                    setShowUserModal(false);
                                    setShowAddUsersModal(false);
                                }}
                                className="px-4 py-2 text-gray-600 hover:text-gray-800"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={showAddUsersModal ? addUsersToGroup : createNewChat}
                                disabled={selectedUsers.length === 0 || (!showAddUsersModal && isGroupChat && !groupName.trim())}
                                className="px-4 py-2 bg-blue-500 text-white rounded disabled:bg-gray-300"
                            >
                                {showAddUsersModal ? 'Add Users' : 'Create Chat'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Delete Confirmation Modal */}
            {showDeleteConfirm && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
                    <div className="bg-white rounded-lg p-6 w-96">
                        <h2 className="text-xl font-semibold mb-4">Delete Chat</h2>
                        <p className="mb-4">Are you sure you want to delete this {activeChat.type === 'group' ? 'group chat' : 'conversation'}? This action cannot be undone.</p>
                        <div className="flex justify-end space-x-2">
                            <button
                                onClick={() => setShowDeleteConfirm(false)}
                                className="px-4 py-2 text-gray-600 hover:text-gray-800"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={deleteChat}
                                className="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
                            >
                                Delete
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Chat; 