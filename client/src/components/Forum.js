import React, { useState, useEffect, useRef, useCallback } from "react";
import { useSelector } from "react-redux";
import { api } from '../config';

const POSTS_PER_PAGE = 10;

// Background pattern for forum
const forumBgStyle = {
  backgroundImage: "url('data:image/svg+xml,%3Csvg width=\"52\" height=\"26\" viewBox=\"0 0 52 26\" xmlns=\"http://www.w3.org/2000/svg\"%3E%3Cg fill=\"none\" fill-rule=\"evenodd\"%3E%3Cg fill=\"%23f0f0f0\" fill-opacity=\"0.8\"%3E%3Cpath d=\"M10 10c0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6h2c0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4 3.314 0 6 2.686 6 6 0 2.21 1.79 4 4 4v2c-3.314 0-6-2.686-6-6 0-2.21-1.79-4-4-4-3.314 0-6-2.686-6-6zm25.464-1.95l8.486 8.486-1.414 1.414-8.486-8.486 1.414-1.414z\"%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E'), linear-gradient(to bottom, rgba(250, 244, 230, 0.8), rgba(243, 244, 246, 0.9) 70%, rgba(209, 213, 219, 1))",
  backgroundRepeat: 'repeat, no-repeat',
  backgroundSize: 'auto, 100% 100%',
};

// Simple dot pattern for hero section
const heroBgStyle = {
  backgroundImage: "radial-gradient(white 2px, transparent 0)",
  backgroundSize: "30px 30px",
  backgroundPosition: "0 0",
  opacity: 0.2
};

const Forum = () => {
  const [posts, setPosts] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortOrder, setSortOrder] = useState("newest"); // newest, oldest
  const [filterRole, setFilterRole] = useState("all"); // all, members, admins
  const [selectedPost, setSelectedPost] = useState(null); // For viewing a single post
  const [newComment, setNewComment] = useState("");
  const [comments, setComments] = useState([]);
  const [usernames, setUsernames] = useState({}); // Store cached usernames
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newPostTitle, setNewPostTitle] = useState("");
  const [newPostContent, setNewPostContent] = useState("");

  const [likedPosts, setLikedPosts] = useState(new Set());
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  const [offset, setOffset] = useState(0);
  const observer = useRef();

  // Accessing the user from Redux state
  const user = useSelector((state) => state.user.user);

  const fetchPosts = useCallback(async() => {
    try {
      const response = await api.get(`/forum/posts`);
      const newPosts = response.data;

      const postsWithLikes = await Promise.all(newPosts.map(async (post) => {
        try {
          const likesResponse = await api.get(`/forum/likes/post/${post.postid}`);
          return {...post, likeCount: likesResponse.data.length};
        } catch (error) {
          console.error("Error fetching likes for post:", post.postid, error);
          return { ...post, likeCount: 0 };
        }
      }));

      setPosts(postsWithLikes);
    } catch (error) {
      console.error("Error fetching posts", error);
    }
  }, []); 

  // Fetch posts and likes when component mounts
  useEffect(() => {
    if (!user) return;
    
    const initializeForum = async () => {
      try {
        // Fetch posts first
        await fetchPosts();
        
        // Then fetch user's likes
        const likesResponse = await api.get(`/forum/likes/user/${user.id}`);
        // Only set likes that exist in the database
        const likedPostIds = new Set(
          likesResponse.data
            .filter(like => like.postid !== null && like.likeid !== null)
            .map(like => like.postid)
        );
        setLikedPosts(likedPostIds);
      } catch (error) {
        console.error("Error initializing forum:", error);
      }
    };

    initializeForum();
  }, [user, fetchPosts]);

  const lastPostRef = useCallback((node) => {
    if (loading || !hasMore || posts.length === 0) return;
    if(observer.current) observer.current.disconnect();
    observer.current = new IntersectionObserver((entries) => {
      if(entries[0].isIntersecting && hasMore) {
        fetchPosts();
      }
    });
    if (node) observer.current.observe(node);
  }, [loading, hasMore, posts.length, fetchPosts]);

  // Handle creating a new post
  const handleCreatePost = async (e) => {
    e.preventDefault();  // Prevent default form submission behavior

    if (!newPostTitle || !newPostContent) {
      alert("Both title and content are required!");  // Ensure no empty post is created
      return;
    }

    try {
      // Sending the new post data to the backend
      await api.post("/forum/posts", {
        title: newPostTitle,
        content: newPostContent,
        userid: user.id, // Attach user ID from Redux
      });

      // Close the modal
      setShowCreateModal(false);
      setNewPostTitle("");
      setNewPostContent("");

      // Reset offset and fetch posts again
      setOffset(0);
      setPosts([]);
      setHasMore(true);
      await fetchPosts();

    } catch (error) {
      console.error("Error creating post:", error);
    }
  };

  const handleViewPost = async (post) => {
    try {
      const response = await api.get(`/forum/posts/${post.postid}`);
      setSelectedPost({
        post: response.data.post,
        replies: response.data.replies,
      });
    } catch (error) {
      console.error("Error fetching post details:", error);
    }
  };

  const handleLikePost = async (postId) => {
    if (!user) {
      alert("Please log in to like posts");
      return;
    }
    
    const isLiked = likedPosts.has(postId);
    
    try {
      if (isLiked) {
        // Get the like ID first
        const likesResponse = await api.get(`/forum/likes/post/${postId}`);
        const userLike = likesResponse.data.find(like => like.userid === user.id);
        if (userLike) {
          // Delete the like
          await api.delete(`/forum/likes/${userLike.likeid}`);
          // Update UI after successful deletion
          setLikedPosts(prev => {
            const updated = new Set(prev);
            updated.delete(postId);
            return updated;
          });
        }
      } else {
        // Create new like
        await api.post("/forum/likes", {
          postid: postId,
          replyid: null,
          userid: user.id,
        });
        // Update UI after successful creation
        setLikedPosts(prev => {
          const updated = new Set(prev);
          updated.add(postId);
          return updated;
        });
      }
      
      // Refresh posts to update like counts
      fetchPosts();

    } catch (error) {
      console.error("Error liking/unliking post:", error);
    }
  };

  // State for liked replies
  const [likedReplies, setLikedReplies] = useState(new Set());
  // State for new reply content
  const [newReplyContent, setNewReplyContent] = useState("");

  // Handle liking a reply
  const handleLikeReply = async (replyId) => {
    if (!user) {
      alert("Please log in to like comments");
      return;
    }
    
    const isLiked = likedReplies.has(replyId);
    
    try {
      if (isLiked) {
        // Get the like ID first
        const likesResponse = await api.get(`/forum/likes/reply/${replyId}`);
        const userLike = likesResponse.data.find(like => like.userid === user.id);
        if (userLike) {
          // Delete the like
          await api.delete(`/forum/likes/${userLike.likeid}`);
          // Update UI after successful deletion
          setLikedReplies(prev => {
            const updated = new Set(prev);
            updated.delete(replyId);
            return updated;
          });
        }
      } else {
        // Create new like
        await api.post("/forum/likes", {
          postid: null,
          replyid: replyId,
          userid: user.id,
        });
        // Update UI after successful creation
        setLikedReplies(prev => {
          const updated = new Set(prev);
          updated.add(replyId);
          return updated;
        });
      }
      
      // Refresh the selected post to update reply like counts
      if (selectedPost) {
        handleViewPost(selectedPost.post);
      }

    } catch (error) {
      console.error("Error liking/unliking reply:", error);
    }
  };

  // Handle adding a reply to a post
  const handleAddReply = async (e) => {
    e.preventDefault();
    
    if (!user) {
      alert("Please log in to comment");
      return;
    }
    
    if (!newReplyContent.trim()) {
      alert("Comment cannot be empty");
      return;
    }
    
    try {
      await api.post(`/forum/posts/${selectedPost.post.postid}/replies`, {
        content: newReplyContent,
        userid: user.id,
      });
      
      // Clear the input
      setNewReplyContent("");
      
      // Refresh the post details to show the new reply
      handleViewPost(selectedPost.post);
      
    } catch (error) {
      console.error("Error adding reply:", error);
    }
  };

  const handleSearch = (e) => {
    setSearchQuery(e.target.value);
  };

  const handleSort = (e) => {
    setSortOrder(e.target.value);
    const sortedPosts = [...posts].sort((a, b) =>
      sortOrder === "newest"
        ? new Date(b.createddate) - new Date(a.createddate)
        : new Date(a.createddate) - new Date(b.createddate)
    );
    setPosts(sortedPosts);
  };

  // Handle filter change
  const handleFilter = (e) => {
    setFilterRole(e.target.value);
  };

  const fetchReplyUsername = async (userid) => {
    if (usernames[userid]) return usernames[userid]; // Use cached username if available

    try {
      const response = await api.get(`/auth/users/${userid}`);
      const username = response.data.username;

      setUsernames((prev) => ({
        ...prev,
        [userid]: username, // Cache the username
      }));

      return username; // Return the fetched username
    } catch (error) {
      console.error("Error finding reply username", error);
      return "Unknown User"; // Fallback for errors
    }
  };

  const handleCommentSubmit = async () => {
    if (!newComment.trim()) return;

    try {
      const response = await api.post(`/forum/posts/${selectedPost.post.postid}/replies`, {
        content: newComment,
        userid: user.id, // Use logged-in user's ID from Redux state
      });

      const newCommentData = {
        ...response.data,
        username: user.username,
      };

      setComments((prevComments) => [
        ...prevComments,
        newCommentData
      ]);

      setSelectedPost((prevSelectedPost) => ({
        ...prevSelectedPost,
        replies: [...prevSelectedPost.replies, newCommentData]
    }));

      setNewComment("");
    } catch (error) {
      console.error("Error adding comment:", error);
    }
  };

  // Filter posts based on user role
  const getFilteredPosts = () => {
    let filteredPosts = [...posts];
    
    // Filter by search query
    if (searchQuery) {
      filteredPosts = filteredPosts.filter(post => 
        post.title.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    
    // Filter by role
    if (filterRole !== "all") {
      filteredPosts = filteredPosts.filter(post => {
        // Get the user's roleid from the post
        const posterRoleId = post.roleid || 1; // Default to guest (1) if not specified
        
        if (filterRole === "members") {
          return posterRoleId < 4; // Members have roleid < 4
        } else if (filterRole === "admins") {
          return posterRoleId >= 4; // Admins have roleid >= 4
        }
        return true;
      });
    }
    
    // Sort posts
    return filteredPosts.sort((a, b) => {
      const dateA = new Date(a.createddate);
      const dateB = new Date(b.createddate);
      
      if (sortOrder === "newest") {
        return dateB - dateA;
      } else {
        return dateA - dateB;
      }
    });
  };

  return (
    <div className="flex flex-col min-h-screen" style={forumBgStyle}>
      {/* Hero Section with Welcome Message */}
      <header className="relative pt-24 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
        {/* Pattern overlay */}
        <div className="absolute inset-0 opacity-20" style={heroBgStyle}></div>
        <div className="max-w-7xl mx-auto">
          <div className="text-center">
            <h1 className="text-4xl md:text-5xl font-bold">Community Forum</h1>
            <p className="mt-3 text-lg md:text-xl text-yellow-100 max-w-3xl mx-auto">
              Connect with other members, share tips, discuss tournaments, and grow the golf community together.
            </p>
          </div>
        </div>
        
        {/* Wave SVG divider */}
        <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
            <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
          </svg>
        </div>
      </header>

      <main className="max-w-5xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8 mb-16">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Forum Discussions</h2>
            <p className="text-gray-600">Join the conversation and share your thoughts with fellow golfers</p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="bg-yellow-500 hover:bg-yellow-600 text-white px-5 py-2 rounded-md font-medium shadow transition-colors flex items-center"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"></path>
            </svg>
            New Discussion
          </button>
        </div>

        <div className="bg-white rounded-xl shadow-md overflow-hidden mb-8">
          <div className="p-4 bg-gray-50 border-b">
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex-1">
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <svg className="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                  </div>
                  <input
                    type="text"
                    placeholder="Search discussions..."
                    value={searchQuery}
                    onChange={handleSearch}
                    className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-yellow-500 focus:border-yellow-500"
                  />
                </div>
              </div>
              <div className="flex gap-2">
                <select
                  value={sortOrder}
                  onChange={handleSort}
                  className="px-3 py-2 border border-gray-300 rounded-md leading-5 bg-white focus:outline-none focus:ring-1 focus:ring-yellow-500 focus:border-yellow-500"
                >
                  <option value="newest">Newest First</option>
                  <option value="oldest">Oldest First</option>
                </select>
                <select
                  value={filterRole}
                  onChange={handleFilter}
                  className="px-3 py-2 border border-gray-300 rounded-md leading-5 bg-white focus:outline-none focus:ring-1 focus:ring-yellow-500 focus:border-yellow-500"
                >
                  <option value="all">All Posts</option>
                  <option value="members">Member Posts</option>
                  <option value="admins">Admin Posts</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        {selectedPost ? (
          <div className="bg-white rounded-xl shadow-md overflow-hidden">
            {/* Post Header */}
            <div className="px-6 py-4 bg-yellow-50 border-b border-yellow-100">
              <div className="flex justify-between items-start">
                <h2 className="text-2xl font-bold text-gray-800">{selectedPost.post.title}</h2>
                <button
                  onClick={() => setSelectedPost(null)}
                  className="ml-4 text-gray-400 hover:text-gray-500 focus:outline-none"
                >
                  <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/>
                  </svg>
                </button>
              </div>
              <div className="flex items-center mt-2 text-sm text-gray-500">
                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
                <span className="mr-4">{selectedPost.post.username || 'Unknown User'}</span>
                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
                <span>{new Date(selectedPost.post.createddate).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}</span>
              </div>
            </div>

            {/* Post Content */}
            <div className="p-6">
              <div className="prose max-w-none mb-6">
                <p className="text-gray-700 whitespace-pre-line">{selectedPost.post.content}</p>
              </div>
              
              {/* Like button for post */}
              <div className="flex justify-end">
                <button
                  onClick={() => handleLikePost(selectedPost.post.postid)}
                  className={`flex items-center px-3 py-1 rounded-full ${
                    likedPosts.has(selectedPost.post.postid)
                      ? "bg-red-50 text-red-600 border border-red-100"
                      : "bg-gray-50 text-gray-500 border border-gray-200 hover:bg-gray-100"
                  } transition-colors`}
                >
                  <svg className="w-5 h-5 mr-1" fill={likedPosts.has(selectedPost.post.postid) ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                  </svg>
                  <span>{selectedPost.post.likeCount || 0}</span>
                </button>
              </div>
            </div>
            
            {/* Comments Section */}
            <div className="px-6 py-4 bg-gray-50 border-t border-gray-100">
              <h3 className="text-lg font-bold text-gray-800 mb-4">
                Comments ({selectedPost.replies.length})
              </h3>
              
              {selectedPost.replies.length === 0 ? (
                <div className="py-8 text-center">
                  <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                  </svg>
                  <p className="text-gray-500">No comments yet. Be the first to comment!</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {selectedPost.replies.map((reply) => (
                    <div key={reply.replyid} className="bg-white p-4 rounded-lg shadow-sm">
                      <div className="prose max-w-none mb-3">
                        <p className="text-gray-700 whitespace-pre-line">{reply.content}</p>
                      </div>
                      <div className="flex justify-between items-center text-sm">
                        <div className="text-gray-500 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                          </svg>
                          <span className="mr-2">{reply.username || 'Unknown User'}</span>
                          <svg className="w-4 h-4 ml-2 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                          </svg>
                          <span>{new Date(reply.createddate).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                        </div>
                        <button
                          onClick={() => handleLikeReply(reply.replyid)}
                          className={`flex items-center ${
                            likedReplies.has(reply.replyid)
                              ? "text-red-500"
                              : "text-gray-400 hover:text-gray-500"
                          }`}
                        >
                          <svg className="w-5 h-5 mr-1" fill={likedReplies.has(reply.replyid) ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                          </svg>
                          <span>{reply.likeCount || 0}</span>
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
            
            {/* Add Comment Form */}
            {user && (
              <div className="px-6 py-4 border-t border-gray-200">
                <h3 className="text-lg font-medium text-gray-800 mb-3">Add a Comment</h3>
                <form onSubmit={handleAddReply}>
                  <textarea
                    value={newReplyContent}
                    onChange={(e) => setNewReplyContent(e.target.value)}
                    className="w-full p-3 border border-gray-300 rounded-md focus:ring-yellow-500 focus:border-yellow-500 mb-3"
                    placeholder="Share your thoughts..."
                    rows="3"
                    required
                  />
                  <div className="flex justify-end">
                    <button
                      type="button"
                      onClick={() => setSelectedPost(null)}
                      className="mr-2 px-4 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500"
                    >
                      Back to Posts
                    </button>
                    <button
                      type="submit"
                      className="px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500"
                    >
                      Post Comment
                    </button>
                  </div>
                </form>
              </div>
            )}
          </div>
        ) : (
          <>
            {loading && posts.length === 0 ? (
              <div className="flex items-center justify-center py-12">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-yellow-500"></div>
              </div>
            ) : (
              <div className="space-y-4">
                {getFilteredPosts().length === 0 ? (
                  <div className="bg-white rounded-xl shadow-md p-8 text-center">
                    <svg className="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z"/>
                    </svg>
                    {searchQuery ? (
                      <p className="text-gray-500">No discussions found matching "{searchQuery}".</p>
                    ) : (
                      <p className="text-gray-500">No discussions yet. Be the first to start a conversation!</p>
                    )}
                    <button
                      onClick={() => setShowCreateModal(true)}
                      className="mt-4 inline-flex items-center px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600"
                    >
                      <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"/>
                      </svg>
                      Start a Discussion
                    </button>
                  </div>
                ) : (
                  getFilteredPosts().map((post, index) => (
                    <div
                      key={post.postid}
                      ref={index === posts.length - 1 ? lastPostRef : null}
                      className="bg-white rounded-xl shadow-md overflow-hidden transition-all duration-300 transform hover:-translate-y-1 hover:shadow-lg"
                    >
                      <div className="p-6">
                        <h3 className="text-xl font-bold text-gray-800 mb-2 hover:text-yellow-600 cursor-pointer" onClick={() => handleViewPost(post)}>
                          {post.title}
                        </h3>
                        <p className="text-gray-600 mb-4 line-clamp-2">
                          {post.content}
                        </p>
                        <div className="flex flex-wrap items-center justify-between">
                          <div className="flex items-center text-sm text-gray-500">
                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                            </svg>
                            <span className="mr-4">{post.username || 'Unknown User'}</span>
                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                            </svg>
                            <span>{new Date(post.createddate).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}</span>
                          </div>
                          <div className="flex items-center mt-2 sm:mt-0 space-x-4">
                            <button
                              onClick={() => handleViewPost(post)}
                              className="flex items-center text-blue-600 hover:text-blue-800"
                            >
                              <svg className="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                              </svg>
                              <span>{post.replyCount || 0}</span>
                            </button>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleLikePost(post.postid);
                              }}
                              className={`flex items-center ${
                                likedPosts.has(post.postid)
                                  ? "text-red-500"
                                  : "text-gray-400 hover:text-gray-500"
                              }`}
                            >
                              <svg className="w-5 h-5 mr-1" fill={likedPosts.has(post.postid) ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/>
                              </svg>
                              <span>{post.likeCount || 0}</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
            {loading && posts.length > 0 && (
              <div className="flex justify-center py-6">
                <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-yellow-500"></div>
              </div>
            )}
          </>
        )}
      </main>

      {/* Create Post Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-xl p-6 w-full max-w-lg animate-fadeIn">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-2xl font-bold text-gray-800">Start a Discussion</h2>
              <button 
                onClick={() => {
                  setShowCreateModal(false);
                  setNewPostTitle("");
                  setNewPostContent("");
                }}
                className="text-gray-400 hover:text-gray-500 focus:outline-none"
              >
                <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>
            
            <form onSubmit={handleCreatePost} className="space-y-4">
              <div>
                <label htmlFor="post-title" className="block text-sm font-medium text-gray-700 mb-1">
                  Title
                </label>
                <input
                  id="post-title"
                  type="text"
                  placeholder="Give your discussion a title"
                  value={newPostTitle}
                  onChange={(e) => setNewPostTitle(e.target.value)}
                  className="w-full p-3 border border-gray-300 rounded-md focus:ring-yellow-500 focus:border-yellow-500"
                  required
                />
              </div>
              
              <div>
                <label htmlFor="post-content" className="block text-sm font-medium text-gray-700 mb-1">
                  Content
                </label>
                <textarea
                  id="post-content"
                  placeholder="Share your thoughts, questions, or ideas with the community..."
                  value={newPostContent}
                  onChange={(e) => setNewPostContent(e.target.value)}
                  className="w-full p-3 border border-gray-300 rounded-md focus:ring-yellow-500 focus:border-yellow-500"
                  rows="6"
                  required
                />
              </div>
              
              <div className="flex justify-end gap-2 pt-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowCreateModal(false);
                    setNewPostTitle("");
                    setNewPostContent("");
                  }}
                  className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500 flex items-center"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                  Create Discussion
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
};

export default Forum;
