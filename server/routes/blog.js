const { Router } = require("express");
const multer = require("multer");
const path = require("path");
const { Blog } = require("../models/blog"); // Ensure Blog is correctly imported
const { User } = require("../models/user");
const { Comment } = require("../models/comment");
const { log } = require("console");
const fs = require("fs");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.resolve(`./public/images/uploads/`));
  },
  filename: function (req, file, cb) {
    const fileName = `${Date.now()}-${file.originalname}`;
    cb(null, fileName);
  },
});

const upload = multer({ storage: storage }); // Corrected the typo here

const router = Router();
router.post("/", upload.single("coverImage"), async (req, res) => {
  if (!req.file) {
    return res
      .status(400)
      .json({ success: false, message: "No file uploaded" });
  }

  const { title, body, user_id } = req.body;

  try {
    const user = await User.findById(user_id);
    const blog = await Blog.create({
      title,
      body,
      createdBy: user._id,
      coverImageURL: `/uploads/${req.file.filename}`,
    });

    return res.json({ success: true, blog });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, message: "Failed to create blog" });
  }
});

router.get("/", async (req, res) => {
  try {
    const allBlogs = await Blog.find({})
      .sort({ createdAt: -1 })
      .populate("createdBy", "fullName");
    return res.json(allBlogs);
  } catch (error) {
    console.error("Error fetching blogs:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

router.get("/user/:createdBy", async (req, res) => {
  try {
    const { createdBy } = req.params;

    const allBlogs = await Blog.find({ createdBy })
      .sort({ createdAt: -1 })
      .populate("createdBy", "fullName");

    return res.json(allBlogs);
  } catch (error) {
    console.error("Error fetching blogs:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/comment/:blogId", async (req, res) => {
  const comment = await Comment.create({
    content: req.body.content,
    blogId: req.params.blogId,
    createdBy: req.body.createdBy,
  });
  return res.json({ comment: comment });
});

router.get("/comment/:id", async (req, res) => {
  const comments = await Comment.find({ blogId: req.params.id })
    .populate({
      path: "createdBy",
      select: "fullName", // Select only the fullName field
    })
    .sort({ createdAt: -1 });
  return res.json(comments);
});

router.delete("/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const blog = await Blog.findById(id);

    if (!blog) {
      return res.status(404).json({ success: false });
    }

    const imagePath = path.join(
      __dirname,
      `../public/images${blog.coverImageURL}`
    );

    fs.stat(imagePath, (err, stats) => {
      if (err) {
        if (err.code === "ENOENT") {
          console.log("Image does not exist");
        } else {
          console.error("Error checking image existence:", err);
        }
      } else {
        fs.unlink(imagePath, (unlinkErr) => {
          if (unlinkErr) {
            console.error("Error deleting image:", unlinkErr);
          }
        });
      }
    });

    await Blog.findByIdAndDelete(id);

    return res.json({ success: true });
  } catch (error) {
    console.error("Error deleting blog:", error);
    return res.status(500).json({ success: false });
  }
});

router.patch("/:id", async (req, res) => {
  const { id } = req.params;
  const { title, body } = req.body;

  try {
    const updatedBlog = await Blog.findByIdAndUpdate(
      id,
      { title, body },
      { new: true }
    );

    if (!updatedBlog) {
      return res.status(404).json({ message: "Blog not found" });
    }

    res.json(true);
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
});

router.post("/getBlogsByIds", async (req, res) => {
  try {
    const { ids } = req.body;    
    if (!ids || !Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ message: "No blog IDs provided." });
    }

    // Fetch blogs from MongoDB where the _id matches any of the provided IDs
    const blogs = await Blog.find({
      _id: { $in: ids },
    });

    if (blogs.length === 0) {
      return res.status(404).json({ message: "No blogs found." });
    }

    // Return the blogs as a response
    res.status(200).json(blogs);
  } catch (err) {
    console.error("Error fetching blogs:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
