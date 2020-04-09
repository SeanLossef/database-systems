import psycopg2
import psycopg2.extras
from data_structures import RecipeInstructions


class RestaurantData:

	def __init__(self, connection_string):
		self.conn = psycopg2.connect(connection_string)

	def check_connectivity(self):
		cursor = self.conn.cursor()
		cursor.execute("SELECT * FROM recipe LIMIT 1")
		records = cursor.fetchall()
		return len(records) == 1

	def find_recipe(self, recipe_name):
		cursor = self.conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
		cursor.execute("SELECT * FROM recipe WHERE LOWER(name) LIKE %s;", ("%%"+recipe_name.lower()+"%%",))
		records = cursor.fetchall()
		return records

	def get_recipe_instructions(self, recipe_name):
		cursor = self.conn.cursor()
		cursor.execute("SELECT recipe.name, recipe.instructions, ingredient.name, recipe_ingredient.amount FROM recipe \
			JOIN recipe_ingredient ON recipe.name=recipe_ingredient.recipe \
			JOIN ingredient ON recipe_ingredient.ingredient=ingredient.code WHERE recipe.name=%s;", (recipe_name,));
		records = cursor.fetchall()

		ingredients = []
		for r in records:
			ingredients.append((r[2], r[3]))

		return RecipeInstructions(records[0][0], records[0][1], ingredients)

	def get_seasonal_menu(self, season):
		recipes = []

		cursor = self.conn.cursor()
		cursor.execute("SELECT recipe.name, a.is_kosher::boolean FROM recipe \
			JOIN ( \
				SELECT recipe_ingredient.recipe, MIN(ingredient.is_kosher::int) AS is_kosher FROM recipe_ingredient \
				JOIN ingredient ON recipe_ingredient.ingredient=ingredient.code \
				GROUP BY recipe_ingredient.recipe \
			) AS a ON recipe.name=a.recipe \
			WHERE recipe.season=%s OR recipe.season='All'", (season,))
		records = cursor.fetchall()

		for r in records:
			recipes.append((r[0], r[1]))

		return recipes

	def update_ingredient_price(self, ingredient_code, price):
		cursor = self.conn.cursor()
		cursor.execute("UPDATE ingredient SET cost_per_unit=%s WHERE code=%s;", (price, ingredient_code,))
		self.conn.commit()
		return cursor.rowcount

	def add_new_recipe(self, recipe_instructions, servings, course, season):
		cursor = self.conn.cursor()
		cursor.execute("INSERT INTO recipe VALUES (%s, %s, %s, %s, %s);", (recipe_instructions.name, recipe_instructions.instructions, servings, course, season))

		for i in recipe_instructions.ingredients:
			cursor.execute("SELECT code FROM ingredient WHERE name=%s;", (i[0],))
			records = cursor.fetchall()
			if (len(records) == 0):
				return False

			cursor.execute("INSERT INTO recipe_ingredient VALUES (%s, %s, %s);", (records[0][0], recipe_instructions.name, i[1]))
		self.conn.commit()

		return True