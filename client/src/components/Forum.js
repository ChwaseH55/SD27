import React, { useState, useEffect, useRef, useCallback } from "react";
import { useSelector } from "react-redux";
import { api } from '../config';

const POSTS_PER_PAGE = 10;

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
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">UCF Golf Club Forum</h1>
      </header>

      <main className="max-w-4xl mx-auto p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-semibold text-black">Latest Posts</h2>
          <button
            onClick={() => setShowCreateModal(true)}
            className="bg-gold text-black px-4 py-2 rounded shadow hover:bg-yellow-400 transition"
          >
            + New Post
          </button>
        </div>

        <div className="flex space-x-4 mb-6">
          <input
            type="text"
            placeholder="Search posts..."
            value={searchQuery}
            onChange={handleSearch}
            className="flex-1 p-2 border border-gray-300 rounded"
          />
          <select
            value={sortOrder}
            onChange={handleSort}
            className="p-2 border border-gray-300 rounded"
          >
            <option value="newest">Newest to Oldest</option>
            <option value="oldest">Oldest to Newest</option>
          </select>
          <select
            value={filterRole}
            onChange={handleFilter}
            className="p-2 border border-gray-300 rounded"
          >
            <option value="all">All</option>
            <option value="members">Members</option>
            <option value="admins">Admins</option>
          </select>
        </div>

        {selectedPost ? (
          <div className="bg-white p-6 rounded-lg shadow-lg">
            <h2 className="text-2xl font-bold mb-2">{selectedPost.post.title}</h2>
            <p className="text-gray-700 mb-4">{selectedPost.post.content}</p>
            <div className="text-gray-500 text-sm mb-6">
              Posted by {selectedPost.post.username || 'Unknown User'} on{" "}
              {new Date(selectedPost.post.createddate).toLocaleDateString()}
            </div>
            
            <div className="border-t pt-4">
              <h3 className="text-xl font-bold mb-4">Comments</h3>
              {selectedPost.replies.length === 0 ? (
                <p className="text-gray-500">No comments yet. Be the first to comment!</p>
              ) : (
                <ul className="space-y-4">
                  {selectedPost.replies.map((reply) => (
                    <li key={reply.replyid} className="border-b pb-4">
                      <p className="text-gray-700">{reply.content}</p>
                      <div className="flex justify-between items-center mt-2">
                        <div className="text-gray-500 text-sm">
                          By {reply.username || 'Unknown User'} on{" "}
                          {new Date(reply.createddate).toLocaleDateString()}
                        </div>
                        <button
                          onClick={() => handleLikeReply(reply.replyid)}
                          className={`flex items-center ${
                            likedReplies.has(reply.replyid)
                              ? "text-red-500"
                              : "text-gray-500"
                          }`}
                        >
                          <span className="mr-1">
                            {likedReplies.has(reply.replyid) ? "♥" : "♡"}
                          </span>
                          {reply.likeCount || 0}
                        </button>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
            
            {user && (
              <div className="mt-6">
                <h3 className="text-lg font-bold mb-2">Add a Comment</h3>
                <form onSubmit={handleAddReply}>
                  <textarea
                    value={newReplyContent}
                    onChange={(e) => setNewReplyContent(e.target.value)}
                    className="w-full p-2 border border-gray-300 rounded mb-2"
                    placeholder="Write your comment here..."
                    required
                  />
                  <button
                    type="submit"
                    className="px-4 py-2 bg-gold text-black rounded"
                  >
                    Post Comment
                  </button>
                </form>
              </div>
            )}
            
            <button
              onClick={() => setSelectedPost(null)}
              className="mt-6 px-4 py-2 border border-gray-300 rounded"
            >
              Back to Posts
            </button>
          </div>
        ) : (
          <>
            {loading && posts.length === 0 ? (
              <div className="text-center py-4">Loading posts...</div>
            ) : (
              <ul className="space-y-4">
                {getFilteredPosts()
                  .map((post, index) => (
                    <li
                      key={post.postid}
                      ref={index === posts.length - 1 ? lastPostRef : null}
                      className="bg-white p-4 shadow rounded-lg border border-gray-200 hover:shadow-lg transition"
                    >
                      <h3 className="text-xl font-bold text-black">{post.title}</h3>
                      <p className="text-gray-700 mt-2">{post.content}</p>
                      <div className="text-gray-500 text-sm mt-2">
                        By {post.username || 'Unknown User'} on{" "}
                        {new Date(post.createddate).toLocaleDateString()}
                      </div>
                      <div className="flex items-center mt-4 space-x-4">
                        <button
                          onClick={() => handleViewPost(post)}
                          className="text-blue-500 hover:underline"
                        >
                          View Discussion ({post.replyCount || 0})
                        </button>
                        <button
                          onClick={() => handleLikePost(post.postid)}
                          className={`flex items-center ${
                            likedPosts.has(post.postid)
                              ? "text-red-500"
                              : "text-gray-500"
                          }`}
                        >
                          <span className="mr-1">
                            {likedPosts.has(post.postid) ? "♥" : "♡"}
                          </span>
                          {post.likeCount || 0}
                        </button>
                      </div>
                    </li>
                  ))}
              </ul>
            )}
            {loading && posts.length > 0 && (
              <div className="text-center py-4">Loading more posts...</div>
            )}
          </>
        )}
      </main>

      {/* Create Post Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg p-6 w-full max-w-lg">
            <h2 className="text-2xl font-bold mb-4">Create New Post</h2>
            <form onSubmit={handleCreatePost}>
              <input
                type="text"
                placeholder="Post Title"
                value={newPostTitle}
                onChange={(e) => setNewPostTitle(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded mb-4"
                required
              />
              <textarea
                placeholder="Post Content"
                value={newPostContent}
                onChange={(e) => setNewPostContent(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded mb-4 h-32"
                required
              />
              <div className="flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => {
                    setShowCreateModal(false);
                    setNewPostTitle("");
                    setNewPostContent("");
                  }}
                  className="px-4 py-2 border border-gray-300 rounded"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-gold text-black rounded"
                >
                  Create Post
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
