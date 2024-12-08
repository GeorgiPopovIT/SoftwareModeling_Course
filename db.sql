CREATE DATABASE YouTube

USE YouTube

CREATE TABLE Account
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	CreatedDate DATETIME NOT NULL,
	Country NVARCHAR(30) NOT NULL
)

CREATE TABLE Channel
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(100) NOT NULL,
	SubscriberId INT REFERENCES Account(Id)
)

CREATE TABLE Video
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(100) NOT NULL,
	[Description] NVARCHAR(MAX),
	CreatedDate DATETIME NOT NULL,
	AccountId INT REFERENCES Account(Id) NOT NULL,
	ChannelId INT REFERENCES Channel(Id) NOT NULL
)

CREATE TABLE ChannelVideo
(
	ChannelId INT REFERENCES Channel(Id),
	VideoId INT REFERENCES Video(Id),
	PRIMARY KEY (ChannelId,VideoId)
)

CREATE TABLE Comment
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Description] NVARCHAR(MAX),
	CreatedDate DATETIME NOT NULL,
	VideoId INT REFERENCES Video(Id) NOT NULL,
	AccountId INT REFERENCES Account(Id) NOT NULL
)

CREATE TABLE [Notification]
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	NotifiedOn DATETIME NOT NULL,
	IsSeen BIT NOT NULL,
	AccountId INT REFERENCES Account(Id) NOT NULL
)

-- Insert into Account table
INSERT INTO Account (FirstName, LastName, CreatedDate, Country)
VALUES 
('John', 'Doe', GETDATE(), 'USA'),
('Jane', 'Smith', GETDATE(), 'UK'),
('Carlos', 'Hernandez', GETDATE(), 'Mexico'),
('Aiko', 'Tanaka', GETDATE(), 'Japan');

-- Insert into Channel table
INSERT INTO Channel (Title, SubscriberId)
VALUES 
('John Tech Reviews', 1),
('Jane Cooking Tips', 2),
('Carlos Travel Vlogs', 3),
('Aiko Art Tutorials', 4);

-- Insert into Video table
INSERT INTO Video (Title, [Description], CreatedDate, AccountId, ChannelId)
VALUES 
('Top 5 Gadgets of 2023', 'A comprehensive review of the top 5 gadgets this year.', GETDATE(), 1, 1),
('Easy Vegan Pancakes', 'Learn how to make simple and delicious vegan pancakes.', GETDATE(), 2, 2),
('Exploring Cancun Beaches', 'A journey through the most beautiful beaches in Cancun.', GETDATE(), 3, 3),
('Watercolor Techniques', 'Basic watercolor techniques for beginners.', GETDATE(), 4, 4);

-- Insert into ChannelVideo table
INSERT INTO ChannelVideo (ChannelId, VideoId)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4);

-- Insert into Comment table
INSERT INTO Comment ([Description], CreatedDate, VideoId, AccountId)
VALUES 
('Great video, very informative!', GETDATE(), 1, 2),
('I love this recipe, thanks for sharing!', GETDATE(), 2, 1),
('The beach looks amazing!', GETDATE(), 3, 4),
('Can’t wait to try this!', GETDATE(), 4, 3);

INSERT INTO [Notification] (Title, NotifiedOn, IsSeen, AccountId)
VALUES 
('New Subscriber', GETDATE(), 0, 1),
('Comment on Your Video', GETDATE(), 0, 2),
('Channel Milestone Reached', GETDATE(), 1, 3),
('Video Approved', GETDATE(), 1, 4);


CREATE PROCEDURE AddNewVideo
    @Title NVARCHAR(100),
    @Description NVARCHAR(MAX),
    @CreatedDate DATETIME,
    @AccountId INT,
    @ChannelId INT
AS
BEGIN
    -- Check if AccountId and ChannelId exist
    IF NOT EXISTS (SELECT 1 FROM Account WHERE Id = @AccountId)
    BEGIN
        PRINT 'Error: AccountId does not exist.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Channel WHERE Id = @ChannelId)
    BEGIN
        PRINT 'Error: ChannelId does not exist.';
        RETURN;
    END

    -- Insert the video into the Video table
    INSERT INTO Video (Title, [Description], CreatedDate, AccountId, ChannelId)
    VALUES (@Title, @Description, @CreatedDate, @AccountId, @ChannelId);

    PRINT 'Video added successfully.';
END;


EXEC AddNewVideo
    @Title = 'Introduction to SQL',
    @Description = 'A beginner-friendly SQL tutorial.',
    @CreatedDate = '2022-12-04',
    @AccountId = 1,
    @ChannelId = 1;

CREATE TRIGGER NotifyOnNewComment
ON Comment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert a notification for each new comment
    INSERT INTO [Notification] (Title, NotifiedOn, IsSeen, AccountId)
    SELECT 
        'New Comment Added',
        GETDATE(),
        0, -- Unseen
        AccountId
    FROM inserted;
END;

CREATE FUNCTION GetVideoCountByChannel
    (@ChannelId INT)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM Video
        WHERE ChannelId = @ChannelId
    );
END;

SELECT dbo.GetVideoCountByChannel(1) AS VideoCount;