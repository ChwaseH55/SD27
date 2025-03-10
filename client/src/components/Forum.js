import React, { useState, useEffect, useRef, useCallback } from "react";
import axios from "axios";
import { useSelector } from "react-redux";  // Import useSelector

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
    if(loading || !hasMore) return;

    setLoading (true);

    try{
      const response = await axios.get(`/api/forum/posts?limit=${POSTS_PER_PAGE}&offset=${offset}`);
      const newPosts = response.data;

      if(response.data.length < POSTS_PER_PAGE){
        setHasMore(false);
      }

      const postsWithLikes = await Promise.all(newPosts.map(async (post) => {
        try {
          const likesResponse = await axios.get(`/api/forum/likes/post/${post.postid}`);
          return {...post, likeCount: likesResponse.data.length};
        } catch (error) {
          console.error("Error fetching likes for post:", post.postid, error);
          return { ...post, likeCount: 0 };
        }
      }));

      setPosts((prevPosts) => [...prevPosts, ...postsWithLikes]);
      setOffset((prevOffset) => prevOffset + POSTS_PER_PAGE);
    }catch (error){
      console.error("Error fetching posts", error);
    }
    setLoading(false);
  }, [loading, hasMore, offset]);

  const fetchPostLikes = async (postId) => {
    try {
      const response = await axios.get(`/api/forum/likes/post/${postId}`);
      setPosts((prevPosts) =>
        prevPosts.map((post) => 
          post.postid === postId ? { ...post, likeCount: response.data.length} : post
        )
      );
    }catch (error) {
      console.error("Error fetching likes for post:", error);
    }
  }

  // Fetch posts when the component mounts
  useEffect(() => {
    if (!user) return;
    const fetchUserLikes = async () => {
      try {
        const response = await axios.get(`/api/forum/likes/user/${user.id}`);
        const likedPostIds = new Set(response.data.map((like) => like.postid));
        setLikedPosts(likedPostIds);
      } catch (error) {
        console.error("Error fetching liked posts: ", error);
      }
    };

    fetchUserLikes();
    setOffset(0);
    fetchPosts();
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
      await axios.post("/api/forum/posts", {
        title: newPostTitle,
        content: newPostContent,
        userid: user.id, // Attach user ID from Redux
      });

      // Close the modal
      setShowCreateModal(false);
      setNewPostTitle("");
      setNewPostContent("");

      // Refetch posts to update the list
      const response = await axios.get("/api/forum/posts");
      setPosts(response.data);
    } catch (error) {
      console.error("Error creating post:", error);
    }
  };

  const handleLike = async (postId) => {
    try {
      const isLiked = likedPosts.has(postId);

      // update UI optimistically 
      setLikedPosts((prev) => {
        const updatedLikes = new Set(prev);
        isLiked ? updatedLikes.delete(postId) : updatedLikes.add(postId);
        return updatedLikes;
      });

      setPosts((prevPosts) =>
        prevPosts.map((post) =>
          post.postid === postId
            ? { ...post, likeCount: isLiked ? post.likeCount - 1 : post.likeCount + 1 }
            : post
        )
      );

      //actual API request to like or unlike
      await axios.post("/api/forum/likes", {
        postid: postId,
        replyid: null, // We're liking a post, not a reply
        userid: user.id, // Use logged-in user's ID from Redux state
      });

    } catch (error) {
      console.error("Error liking post:", error);
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

  const handleFilter = (e) => {
    setFilterRole(e.target.value);
  };

  const fetchPostDetails = async (postId) => {
    try {
      const response = await axios.get(`/api/forum/posts/${postId}`);
      setSelectedPost({
        post: response.data.post,
        comments: response.data.replies,
      });
    } catch (error) {
      console.error("Error fetching post details:", error);
    }
  };

  const fetchReplyUsername = async (userid) => {
    if (usernames[userid]) return usernames[userid]; // Use cached username if available

    try {
      const response = await axios.get(`/api/auth/users/${userid}`);
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
      const response = await axios.post(`/api/forum/posts/${selectedPost.post.postid}/replies`, {
        content: newComment,
        userid: user.id, // Use logged-in user's ID from Redux state
      });
      setComments((prevComments) => [
        ...prevComments,
        response.data,
      ]);
      setNewComment("");
    } catch (error) {
      console.error("Error adding comment:", error);
    }
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
          <div className="bg-white p-6 shadow rounded-lg border border-gray-200">
            <button
              onClick={() => setSelectedPost(null)}
              className="text-gray-600 text-sm underline"
            >
              Back to Posts
            </button>
            <h2 className="text-2xl font-bold mt-4">{selectedPost.post.title}</h2>
            <p className="text-gray-700 mt-2">{selectedPost.post.content}</p>
            <div className="mt-4">
              <h3 className="text-xl font-semibold">Comments</h3>
              <ul className="space-y-2 mt-2">
                {selectedPost.comments.map((comment) => (
                  <li key={comment.replyid} className="bg-gray-100 p-2 rounded">
                    <p>{comment.content}</p>
                    <div className="text-gray-500 text-sm">
                      By{" "}
                      {comment.username || "Unknown User"}
                    </div>
                  </li>
                ))}
              </ul>
              <textarea
                className="w-full mt-4 p-2 border border-gray-300 rounded"
                placeholder="Write a comment..."
                value={newComment}
                onChange={(e) => setNewComment(e.target.value)}
              />
              <button
                onClick={handleCommentSubmit}
                className="bg-gold text-black px-4 py-2 rounded mt-2"
              >
                Submit Comment
              </button>
            </div>
          </div>
        ) : (
          <ul className="space-y-4">
            {posts
              .filter((post) =>
                post.title.toLowerCase().includes(searchQuery.toLowerCase())
              )
              .map((post, index) => (
                <li
                  key={post.postid}
                  ref={index === posts.length - 1 ? lastPostRef : null}
                  className="bg-white p-4 shadow rounded-lg border border-gray-200 hover:shadow-lg transition"
                >
                  <h3 className="text-xl font-bold text-black">{post.title}</h3>
                  <p className="text-gray-700 mt-2">{post.content}</p>
                  <div className="text-gray-500 text-sm mt-2">
                    By {post.username} on{" "}
                    {new Date(post.createddate).toLocaleDateString()}
                  </div>
                  <div className="flex items-center mt-4 space-x-4">
                    <button
                      onClick={() => handleLike(post.postid)}
                      className={`text-sm ${likedPosts.has(post.postid) ? "text-red-500" : "text-gray-600"
                        }`}
                    >
                      {likedPosts.has(post.postid) ? "❤️ Unlike" : "👍 Like"} {post.likeCount || 0}
                    </button>
                    <button
                      onClick={() => fetchPostDetails(post.postid)}
                      className="text-sm underline"
                    >
                      View Details
                    </button>
                  </div>
                </li>
              ))}
          </ul>
        )}
      </main>

      {/* Create Post Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-gray-800 bg-opacity-50">
          <div className="bg-white p-6 rounded-lg shadow-lg w-1/2">
            <h2 className="text-2xl font-bold mb-4">Create a New Post</h2>
            <form onSubmit={handleCreatePost}>
              <div>
                <input
                  type="text"
                  placeholder="Post Title"
                  value={newPostTitle}
                  onChange={(e) => setNewPostTitle(e.target.value)}
                  className="w-full p-2 mb-4 border border-gray-300 rounded"
                  required
                />
                <textarea
                  placeholder="Post Content"
                  value={newPostContent}
                  onChange={(e) => setNewPostContent(e.target.value)}
                  className="w-full p-2 mb-4 border border-gray-300 rounded"
                  required
                />
              </div>
              <div className="flex justify-end">
                <button
                  type="submit"
                  className="bg-gold text-black px-6 py-2 rounded shadow hover:bg-yellow-400 transition"
                >
                  Submit
                </button>
              </div>
            </form>
            <button
              onClick={() => setShowCreateModal(false)} // Close modal without submitting
              className="absolute top-2 right-2 text-black font-bold"
            >
              X
            </button>
          </div>
        </div>
      )}

    </div>
  );
};

export default Forum;
