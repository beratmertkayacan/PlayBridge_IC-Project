from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class CamelModel(BaseModel):
    """
    Python tarafında snake_case yazıyoruz (idiomatic), ama JSON'a
    camelCase olarak çıkıyor/giriyor — Swift'in Codable'ı ile
    birebir eşleşsin diye. Örn: parent_setup_minutes <-> parentSetupMinutes
    """
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
    )


class ActivityRequest(CamelModel):
    age_range: str
    interests: list[str]
    available_materials: list[str]
    duration_minutes: int
    parent_setup_minutes: int
    mode: str
    # Ebeveynin bulunduğu ortam: "Living room", "In the kitchen",
    # "In the car", "Outdoor". iOS'ta seçilmesi zorunlu değil, bu yüzden
    # varsayılanı None — eski istemciler de kırılmadan çalışmaya devam eder.
    location: str | None = None


class PlayActivity(CamelModel):
    id: str
    title: str
    summary: str
    setup_time_minutes: int
    activity_time_minutes: int
    materials: list[str]
    setup_steps: list[str]
    child_instructions: list[str]
    imagination_prompts: list[str]
    screen_required: bool


class SafetyReview(CamelModel):
    reviewed: bool
    safe: bool
    notes: list[str]


class GeneratedActivityResponse(CamelModel):
    activity: PlayActivity
    safety: SafetyReview


class MealPromptRequest(CamelModel):
    age_range: str


class MealPromptResponse(CamelModel):
    prompt: str


class ScreenToPlayRequest(CamelModel):
    age_range: str
    screen_topic: str
