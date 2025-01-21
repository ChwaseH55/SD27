import React, { useState } from "react";

const Forum = () => {
  const [posts, setPosts] = useState([
    {
      id: 1,
      title: "Welcome to the Golf Club Forum!",
      author: "Admin",
      summary: "Introduce yourself and get to know fellow members.",
      date: "2025-01-14",
      likes: 0,
      liked: false,
    },
    {
      id: 2,
      title: "Upcoming Tournament Discussion",
      author: "Coach",
      summary: "Share your thoughts about the next tournament!",
      date: "2025-01-12",
      likes: 2,
      liked: false,
    },
  ]);

  const [searchQuery, setSearchQuery] = useState("");
  const [sortOrder, setSortOrder] = useState("newest"); // newest, oldest
  const [filterRole, setFilterRole] = useState("all"); // all, members, admins
  const [selectedPost, setSelectedPost] = useState(null); // For viewing a single post
  const [newComment, setNewComment] = useState("");
  const [comments, setComments] = useState([]);

  const handleCreatePost = () => {
    // Navigate to the create post page or open a modal
    alert("Redirect to create post functionality");
  };

  const handleLike = (postId) => {
    setPosts((prevPosts) =>
      prevPosts.map((post) =>
        post.id === postId ? { ...post, likes: post.likes + 1, liked: true } : post
      )
    );
  };

  const handleSearch = (e) => {
    setSearchQuery(e.target.value);
  };

  const handleSort = (e) => {
    setSortOrder(e.target.value);
    const sortedPosts = [...posts].sort((a, b) =>
      sortOrder === "newest"
        ? new Date(b.date) - new Date(a.date)
        : new Date(a.date) - new Date(b.date)
    );
    setPosts(sortedPosts);
  };

  const handleFilter = (e) => {
    setFilterRole(e.target.value);
  };

  const fetchPostDetails = (postId) => {
    const post = posts.find((p) => p.id === postId);
    const mockComments = [
      { id: 1, content: "Great post!", author: "Member1" },
      { id: 2, content: "Excited for the tournament!", author: "Member2" },
    ];
    setSelectedPost({ post, comments: mockComments });
  };

  const handleCommentSubmit = () => {
    if (!newComment.trim()) return;
    setComments((prevComments) => [
      ...prevComments,
      { id: comments.length + 1, content: newComment, author: "You" },
    ]);
    setNewComment("");
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
            onClick={handleCreatePost}
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
            <p className="text-gray-700 mt-2">{selectedPost.post.summary}</p>
            <div className="mt-4">
              <h3 className="text-xl font-semibold">Comments</h3>
              <ul className="space-y-2 mt-2">
                {selectedPost.comments.map((comment) => (
                  <li key={comment.id} className="bg-gray-100 p-2 rounded">
                    <p>{comment.content}</p>
                    <div className="text-gray-500 text-sm">
                      By {comment.author}
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
              .map((post) => (
                <li
                  key={post.id}
                  className="bg-white p-4 shadow rounded-lg border border-gray-200 hover:shadow-lg transition"
                >
                  <h3 className="text-xl font-bold text-black">{post.title}</h3>
                  <p className="text-gray-700 mt-2">{post.summary}</p>
                  <div className="text-gray-500 text-sm mt-2">
                    By {post.author} on{" "}
                    {new Date(post.date).toLocaleDateString()}
                  </div>
                  <div className="flex items-center mt-4 space-x-4">
                    <button
                      onClick={() => handleLike(post.id)}
                      className="text-sm text-gray-600"
                      disabled={post.liked}
                    >
                      👍 {post.likes} Likes
                    </button>
                    <button
                      onClick={() => fetchPostDetails(post.id)}
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
    </div>
  );
};

export default Forum;
