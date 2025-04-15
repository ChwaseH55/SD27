import React, { useState, useEffect, useRef } from 'react';
import { ref, push, onValue, off, query, orderByChild, get, update, remove, set } from 'firebase/database';
import { getStorage, ref as storageRef, uploadBytes, getDownloadURL } from 'firebase/storage';
import { useSelector } from 'react-redux';
import { database } from '../firebase';
import { api } from '../config';
import UserAvatar from './UserAvatar';
import { motion, AnimatePresence } from 'framer-motion';
import { FiSend, FiImage, FiEdit2, FiTrash2, FiUsers, FiUserPlus, FiX } from 'react-icons/fi';

// Modern gradient background
const mainBgStyle = {
  backgroundImage: "url('data:image/svg+xml,%3Csvg width=\"52\" height=\"26\" viewBox=\"0 0 52 26\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cg fill=\"none\" fill-rule=\"evenodd\"%3E%3Cg fill=\"%23f0f0f0\" fill-opacity=\"0.8\"%3E%3Cpath d=\"M10 10c0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6h2c0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4v2c-3.314 0-6-2.686-6-6 0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6zm25.464-1.95l8.486 8.486-1.414 1.414-8.486-8.486 1.414-1.414z\"%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E'), linear-gradient(to bottom, rgba(250, 244, 230, 0.8), rgba(243, 244, 246, 0.9) 70%, rgba(209, 213, 219, 1))",
  backgroundRepeat: 'repeat, no-repeat',
  backgroundSize: 'auto, 100% 100%',
};

// Modern dot pattern
const heroBgStyle = {
  backgroundImage: "radial-gradient(circle at 1px 1px, #e2e8f0 1px, transparent 0)",
  backgroundSize: "24px 24px",
  opacity: 0.5
};

// Enhanced global styles
const globalStyles = `
  @keyframes float {
    0% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
    100% { transform: translateY(0px); }
  }
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  @keyframes slideIn {
    from { transform: translateX(-100%); }
    to { transform: translateX(0); }
  }
  .chat-container {
    height: calc(100vh - 64px);
    display: flex;
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    overflow: hidden;
    transition: all 0.3s;
  }
  .chat-sidebar {
    width: 300px;
    border-right: 1px solid #e2e8f0;
    background: white;
    display: flex;
    flex-direction: column;
  }
  .chat-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    background: #f8fafc;
  }
  .message-bubble {
    max-width: 70%;
    padding: 12px 16px;
    border-radius: 16px;
    margin: 4px 0;
    position: relative;
    animation: fadeIn 0.3s ease-out;
    word-wrap: break-word;
  }
  .message-bubble.sent {
    background: #eab308;
    color: white;
    margin-left: auto;
    border-bottom-right-radius: 4px;
  }
  .message-bubble.received {
    background: white;
    color: #1e293b;
    margin-right: auto;
    border-bottom-left-radius: 4px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  }
  .message-input-container {
    padding: 16px;
    background: white;
    border-top: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .message-input {
    flex: 1;
    padding: 12px 16px;
    border: 1px solid #e2e8f0;
    border-radius: 24px;
    outline: none;
    font-size: 14px;
    transition: all 0.2s;
  }
  .message-input:focus {
    border-color: #eab308;
    box-shadow: 0 0 0 3px rgba(234, 179, 8, 0.1);
  }
  .send-button {
    background: #eab308;
    color: white;
    border: none;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.2s;
  }
  .send-button:hover {
    background: #ca8a04;
    transform: scale(1.05);
  }
  .chat-list-item {
    padding: 12px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    cursor: pointer;
    transition: all 0.2s;
    border-bottom: 1px solid #e2e8f0;
  }
  .chat-list-item:hover {
    background: #fef3c7;
  }
  .chat-list-item.active {
    background: #fef3c7;
    border-left: 4px solid #eab308;
  }
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }
  .modal-content {
    background: white;
    border-radius: 12px;
    padding: 24px;
    width: 90%;
    max-width: 500px;
    max-height: 90vh;
    overflow-y: auto;
    position: relative;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  }
  .user-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 12px;
    margin-top: 16px;
  }
  .user-item {
    padding: 12px;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    transition: all 0.2s;
  }
  .user-item:hover {
    background: #fef3c7;
    border-color: #eab308;
  }
  .user-item.selected {
    background: #fef3c7;
    border-color: #eab308;
  }
  .message-image {
    max-width: 100%;
    max-height: 300px;
    border-radius: 8px;
    cursor: pointer;
    transition: transform 0.2s;
  }
  .message-image:hover {
    transform: scale(1.02);
  }
  .chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
`;

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
                        } else if (chat.type === 'group') {
                            // Ensure group chat has a name
                            return {
                                ...chat,
                                name: chat.name || 'Group Chat'
                            };
                        }
                        return chat;
                    });

                    // Sort chats by last message timestamp
                    chatsWithDetails.sort((a, b) => {
                        const aTime = a.lastMessage?.timestamp || 0;
                        const bTime = b.lastMessage?.timestamp || 0;
                        return bTime - aTime;
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
                        } else if (chat.type === 'group') {
                            return {
                                ...chat,
                                name: chat.name || 'Group Chat'
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
                const messagesArray = Object.entries(messagesData)
                    .map(([id, message]) => ({
                        id,
                        ...message
                    }))
                    .sort((a, b) => a.timestamp - b.timestamp); // Sort messages by timestamp
                
                setMessages(messagesArray);

                // Update last message in chat
                if (messagesArray.length > 0) {
                    const lastMessage = messagesArray[messagesArray.length - 1];
                    const chatRef = ref(database, `chats/${activeChat.id}`);
                    update(chatRef, {
                        lastMessage: {
                            text: lastMessage.text,
                            timestamp: lastMessage.timestamp
                        }
                    });
                }
            } else {
                setMessages([]);
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
        const lastMessage = chat.lastMessage || { text: 'No messages yet', timestamp: 0 };
        const timestamp = new Date(lastMessage.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        return (
            <motion.div
                className={`chat-list-item ${isActive ? 'active' : ''}`}
                onClick={onClick}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
            >
                <UserAvatar
                    user={chat.type === 'direct' ? chat.otherUser : chat}
                    size={40}
                />
                <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-center">
                        <h3 className="font-medium text-gray-900 truncate">
                            {chat.type === 'direct' 
                                ? `${chat.otherUser.firstname} ${chat.otherUser.lastname}`
                                : chat.name || 'Group Chat'}
                        </h3>
                        <span className="text-xs text-gray-500">{timestamp}</span>
                    </div>
                    <p className="text-sm text-gray-500 truncate">{lastMessage.text}</p>
                </div>
            </motion.div>
        );
    };

    const Message = ({ message, currentUser, onReply, onEdit, onDelete }) => {
        const isSent = message.senderId === currentUser.id.toString();
        const timestamp = new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        return (
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className={`message-bubble ${isSent ? 'sent' : 'received'}`}
            >
                <div className="flex items-start gap-2">
                    {!isSent && (
                        <UserAvatar
                            user={{ id: message.senderId, username: message.senderName }}
                            size={32}
                        />
                    )}
                    <div className="flex-1 min-w-0">
                        {!isSent && (
                            <div className="text-xs text-gray-500 mb-1">{message.senderName}</div>
                        )}
                        {message.image ? (
                            <img
                                src={message.image}
                                alt="Shared"
                                className="message-image"
                                onClick={() => window.open(message.image, '_blank')}
                            />
                        ) : (
                            <p className="text-sm break-words">{message.text}</p>
                        )}
                        <div className="text-xs mt-1 opacity-70">{timestamp}</div>
                    </div>
                    {isSent && (
                        <div className="flex gap-1">
                            <button
                                onClick={() => onEdit(message, 'edit')}
                                className="p-1 hover:bg-white/10 rounded-full"
                            >
                                <FiEdit2 size={14} />
                            </button>
                            <button
                                onClick={() => onDelete(message, 'delete')}
                                className="p-1 hover:bg-white/10 rounded-full"
                            >
                                <FiTrash2 size={14} />
                            </button>
                        </div>
                    )}
                </div>
            </motion.div>
        );
    };

    return (
        <div className="chat-container" style={mainBgStyle}>
            <style>{globalStyles}</style>
            
            <div className="chat-sidebar">
                <div className="p-4 border-b">
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="text-xl font-semibold text-gray-900">Chats</h2>
                        <div className="flex gap-2">
                            <button
                                onClick={() => openNewChatModal(false)}
                                className="p-2 hover:bg-gray-100 rounded-full"
                                title="New Message"
                            >
                                <FiUserPlus size={20} />
                            </button>
                            <button
                                onClick={() => openNewChatModal(true)}
                                className="p-2 hover:bg-gray-100 rounded-full"
                                title="Create Group"
                            >
                                <FiUsers size={20} />
                            </button>
                        </div>
                    </div>
                    <div className="flex gap-2">
                        <button 
                            onClick={() => openNewChatModal(false)}
                            className="flex-1 px-4 py-2 bg-yellow-500 text-white rounded-md text-sm hover:bg-yellow-600 transition-colors flex items-center justify-center gap-2"
                        >
                            <FiUserPlus size={16} />
                            New Message
                        </button>
                        <button 
                            onClick={() => openNewChatModal(true)}
                            className="flex-1 px-4 py-2 bg-gray-700 text-white rounded-md text-sm hover:bg-gray-800 transition-colors flex items-center justify-center gap-2"
                        >
                            <FiUsers size={16} />
                            Create Group
                        </button>
                    </div>
                </div>
                
                <div className="flex-1 overflow-y-auto">
                    <AnimatePresence>
                        {chats.map((chat) => (
                            <motion.div
                                key={chat.id}
                                initial={{ opacity: 0, x: -20 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: -20 }}
                            >
                                <ChatListItem
                                    chat={chat}
                                    isActive={activeChat?.id === chat.id}
                                    onClick={() => setActiveChat(chat)}
                                    currentUser={currentUser}
                                />
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </div>
            </div>

            <div className="chat-main">
                {activeChat ? (
                    <>
                        <div className="p-4 border-b bg-white">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <UserAvatar
                                        user={activeChat.type === 'direct' ? activeChat.otherUser : activeChat}
                                        size={40}
                                    />
                                    <div>
                                        <h3 className="font-medium text-gray-900">
                                            {activeChat.type === 'direct'
                                                ? `${activeChat.otherUser.firstname} ${activeChat.otherUser.lastname}`
                                                : activeChat.name}
                                        </h3>
                                        <p className="text-sm text-gray-500">
                                            {activeChat.type === 'group' ? `${Object.keys(activeChat.participants).length} members` : 'Online'}
                                        </p>
                                    </div>
                                </div>
                                {activeChat.type === 'group' && (
                                    <div className="flex gap-2">
                                        <button
                                            onClick={() => {
                                                setIsGroupChat(true);
                                                setSelectedUsers([]);
                                                fetchAvailableUsers();
                                                setShowAddUsersModal(true);
                                            }}
                                            className="px-3 py-1 bg-yellow-500 text-white rounded-md text-sm hover:bg-yellow-600 transition-colors"
                                        >
                                            Add Users
                                        </button>
                                        {activeChat.createdBy === currentUser.id.toString() && (
                                            <button
                                                onClick={() => setShowDeleteConfirm(true)}
                                                className="px-3 py-1 bg-red-500 text-white rounded-md text-sm hover:bg-red-600 transition-colors"
                                            >
                                                Delete Chat
                                            </button>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>

                        <div className="chat-messages">
                            <AnimatePresence>
                                {messages.map((message) => (
                                    <Message
                                        key={message.id}
                                        message={message}
                                        currentUser={currentUser}
                                        onReply={setReplyingTo}
                                        onEdit={handleMessageAction}
                                        onDelete={handleMessageAction}
                                    />
                                ))}
                            </AnimatePresence>
                            <div ref={messagesEndRef} />
                        </div>

                        <div className="message-input-container">
                            {replyingTo && (
                                <div className="mb-2 p-2 bg-gray-100 rounded-md flex justify-between items-center">
                                    <div className="text-sm text-gray-600">
                                        <span className="font-medium">Replying to:</span> {replyingTo.text}
                                    </div>
                                    <button 
                                        onClick={() => setReplyingTo(null)}
                                        className="text-gray-400 hover:text-gray-600"
                                    >
                                        <FiX size={16} />
                                    </button>
                                </div>
                            )}
                            <input
                                type="text"
                                value={newMessage}
                                onChange={(e) => setNewMessage(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && sendMessage(e)}
                                placeholder={editingMessage ? "Edit your message..." : "Type a message..."}
                                className="message-input"
                            />
                            <input
                                type="file"
                                ref={fileInputRef}
                                onChange={handleImageUpload}
                                accept="image/*"
                                className="hidden"
                            />
                            <button
                                onClick={() => fileInputRef.current?.click()}
                                className="p-2 hover:bg-gray-100 rounded-full"
                            >
                                <FiImage size={20} />
                            </button>
                            <button
                                onClick={sendMessage}
                                className="send-button"
                            >
                                <FiSend size={20} />
                            </button>
                        </div>
                    </>
                ) : (
                    <div className="flex-1 flex items-center justify-center">
                        <div className="text-center">
                            <FiUsers size={48} className="mx-auto text-gray-400 mb-4" />
                            <h3 className="text-xl font-medium text-gray-900 mb-2">Welcome to Chat</h3>
                            <p className="text-gray-500">Select a chat or start a new conversation</p>
                        </div>
                    </div>
                )}
            </div>

            {/* Modals */}
            <AnimatePresence>
                {showUserModal && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                    >
                        <motion.div
                            initial={{ scale: 0.95, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.95, opacity: 0 }}
                            className="modal-content"
                        >
                            <h2 className="text-xl font-semibold mb-4">
                                {isGroupChat ? 'Create New Group' : 'New Chat'}
                            </h2>
                            {isGroupChat && (
                                <input
                                    type="text"
                                    value={groupName}
                                    onChange={(e) => setGroupName(e.target.value)}
                                    placeholder="Group Name"
                                    className="w-full p-2 border rounded-lg mb-4"
                                />
                            )}
                            <div className="user-list">
                                {availableUsers.map((user) => (
                                    <motion.div
                                        key={user.id}
                                        className={`user-item ${selectedUsers.find(u => u.id === user.id) ? 'selected' : ''}`}
                                        onClick={() => toggleUserSelection(user)}
                                        whileHover={{ scale: 1.02 }}
                                        whileTap={{ scale: 0.98 }}
                                    >
                                        <UserAvatar user={user} size={32} />
                                        <span>{user.firstname} {user.lastname}</span>
                                    </motion.div>
                                ))}
                            </div>
                            <div className="flex justify-end gap-2 mt-4">
                                <button
                                    onClick={() => setShowUserModal(false)}
                                    className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={createNewChat}
                                    className="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg transition-colors duration-300"
                                >
                                    Create
                                </button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}

                {/* Delete Confirmation Modal */}
                {showDeleteConfirm && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                    >
                        <motion.div
                            initial={{ scale: 0.95, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.95, opacity: 0 }}
                            className="modal-content"
                        >
                            <h2 className="text-xl font-semibold mb-4">Delete Chat</h2>
                            <p className="text-gray-600 mb-6">
                                Are you sure you want to delete this chat? This action cannot be undone and all messages will be permanently deleted.
                            </p>
                            <div className="flex justify-end gap-2">
                                <button
                                    onClick={() => setShowDeleteConfirm(false)}
                                    className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg"
                                >
                                    Cancel
                                </button>
                                <button
                                    onClick={deleteChat}
                                    className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors"
                                >
                                    Delete
                                </button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default Chat; 