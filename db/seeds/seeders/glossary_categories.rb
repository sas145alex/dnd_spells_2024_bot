pp "Performing - #{__FILE__}"

pp "Before count = #{GlossaryCategory.count}"

GlossaryCategory.find_or_create_by!(id: GlossaryCategory::DEFAULT_CATEGORY_ID) do |category|
  category.title = "Default"
end

pp "After count = #{GlossaryCategory.count}"
