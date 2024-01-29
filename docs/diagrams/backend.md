```mermaid
classDiagram
direction LR
namespace Authorization {
    class login_controller {
        <<route /api/login>>
        + POST() : json
    }

    class logout_controller {
        <<route /api/logout>>
        + POST() : json
    }

    class register_controller {
        <<route /api/register>>
        + POST() : json
    }
} 

namespace Posts {
    class post_controller {
        <<route /api/post/:id>>
        + GET() : json
        + PUT() : json
    }

    class all_posts_controller {
        <<route /api/post/all>>
        + GET() : json
    }
}

namespace Relationships {
    class relationship_controller {
        <<route /api/relationship>>
        + GET() : json
        + PUT() : json
    }
}

namespace Settings {
    class settings_controller {
        <<route /api/settings>>
        + GET() : json
        + PUT() : json
    }
}

namespace Search {
    class search_controller {
        <<route /api/search>>
        + GET() : json
    }
}
namespace Static {
    class static_controller1 {
        <<route /static/uploads/:id/:name>>
        + GET() : file?
    }

    class static_controller2 {
        <<route /assets/:name>>
        + GET() : file?
    }

    class static_controller3 {
        <<route /assets/:dir/:name>>
        + GET() : file?
    }

    class static_controller4 {
        <<route /assets/:dir1/:dir2/:name>>
        + GET() : file?
    }
}

DBManager ..|> QueueItem : uses
RelationshipDAO <|.. DBManager : used by
ScriptDAO <|.. DBManager : used by
SearchDAO <|.. DBManager : used by
TokenDAO <|.. DBManager : used by
UserDAO <|.. DBManager : used by
VoteDAO <|.. DBManager : used by
PostDAO <|.. DBManager : used by

PostDAO ..|> Post : uses
Relationship <|.. RelationshipDAO : uses
RelationshipType <.. Relationship : uses
Script <|.. ScriptDAO : uses
User <|.. UserDAO: uses
Vote <|.. VoteDAO : uses
Post ..|> VoteDAO : used by
PostDAO <|.. VoteDAO : uses
VoteValue <|.. Vote : uses

namespace Database {
class DBManager {
    - cursor
    - running: bool
    - thread: Thread
    - queue: PriorityQueue~QueueItem~
    - results: dict
    + execute(statement: str, values: tuple) : list~tuple~
    + execute_multiple(statement: str, values: list~tuple~) : list~list~tuple~~
    + die()
    - post_init()
    - restart_connection
    - run_forever()
    - execute(statement: str, values: tuple) : list~tuple~
    - random_id() : int
}


class QueueItem {
    + statement: str
    + values: tuple
    + id: int
    + count: int
}

class User {
    + id: Uuid
    + first_name: str
    + profile_picture: str
    + middle_name: str
    + last_name: str
    + join_time: datetime
    + country: str
    + city: str
    + education: str
    + extra: str
    + banner_picture: str?
    + email: str
    + password: str?
    + permissions: int
    + from_db(row: tuple)$: User
    + is_ok(): bool
    + is_admin(): bool
    + sanitize(): User
}

class UserDAO {
    + get_user_by_id(id: Uuid)$ : User?
    + get_user_by_email(email: str)$ : User?
    + register_user(user: User)$
    + user_exists(email: str)$ : bool
    + correct_password(email: str, password: str)$ : bool
    + delete_user(id_: uuid.UUID)$
}

class Post {
    + id: Uuid
    + owner_id: Uuid
    + create_time: datetime
    + likes: int
    + dislikes: int
    + text: str
    + image: str?
    + video: str?
    + audio: str?
    + from_db(row: tuple)$: Post
}

class PostDAO {
    + create_post(post: Post)$
    + get_visible_posts(user: Post?, start: int, end: int)$: list~PostWrapper~
    + get_post_by_id(id: Uuid): Post?
    + add_vote(post_id: Uuid, vote: Vote.Value)
    + remove_vote(post_id: Uuid, vote: Vote.Value)
    + get_post_count_by_user(user_id: Uuid): int
    + get_score_by_user(user_id: Uuid): int
}

class Relationship {
    + id: Uuid
    + from: Uuid
    + to: Uuid
    + type: Relationship.Type
    + change_time: datetime
    + from_db(row: tuple)$: Relationship
}

class RelationshipDAO {
    + upsert(rel: Relationship)$
    + get_relationship_by_id(from_id: Uuid, to_id: Uuid)$: Relationship?
    + get_relationship(id1: Uuid, id2: Uuid)$: dict
    + get_relationship_count(user_id: Uuid, type: Relationship.Type)$: int
}

class RelationshipType {
    <<enum>>
    None
    RequestPending
    RequestSent
    Friend
    Blocked
    Hidden
}

class ScriptDAO {
    + add(script: Script)$
    + get(id: Uuid)$: Script?
}

class Script {
    + id: Uuid
    + author_id: Uuid
    + code: str
    + fernet: Fernet
    + encrypt()
    + from_db(row: tuple)$: Script
}

class SearchDAO {
    + search_name(prompt: str, max: int): list~User~
    + search_page(prompt: str, max: int): list~Page~
}

class TokenDAO {
    + insert(jwt: str)$
    + is_valid(jwt: str)$: bool
    + invalidate(jwt: str)$
}

class Vote {
    + id: Uuid
    + parent_id: Uuid
    + author_id: Uuid
    + value: VoteValue
    + create_time: datetime
    + from_db(row: tuple)$: Vote
}

class VoteDAO {
    + add(vote: Vote)$
    + get_vote(parent: Uuid, author: Uuid)$: Vote?
    + get_vote_by_id(id: Uuid)$: Vote?
    + delete(vote_id: Uuid)$
    + update_votes_for_post(post: Post): Post
}

class VoteValue {
    <<enum>>
    Upvote
    Downvote
    Clear
}
}


Email ..> Sender : uses
WelcomeEmail --|> Email : implements

namespace Emails {
class Email {
    - receiver: str
    - subject: str
    - text: str
    - html: str
    - message: MIME
    + format()*: Email
    - post_init()
}

class WelcomeEmail {
    - user: User
    + format() -> Email
    - post_init()
}

class Sender {
    - FROM$: str
    - PASSWORD$: str
    - mails: list~Email~
    + queue(email: Email)$
    - send_single(email: Email)$
    - send()$
}
}

namespace QrCode {
    class QrCodeBuilder {
        - data: str
        - logo: Image
        - qr_img: Image
        + make(fill_color: str?, back_color: str?)
        + save(author_id: Uuid)
        - post_init()
        - random_color(): tuple
    }
}
```
