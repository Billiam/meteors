class Collider
  def initialize(width, height)
    @width = width
    @height = height
  end

  def create_quad(list)
    quad = RQuad::QuadTree.new(RQuad::Vector.new(0, @height), RQuad::Vector.new(@width, 0))
    list.each do |item|
      quad.add(RQuad::QuadTreePayload.new(item.vector, item))
    end
    quad
  end

  def update(asteroids, shots, ship)
    @asteroids_quad = create_quad asteroids
    @shots = shots
    @ship = ship
  end

  # Create a two corner bounding box to define the search region
  def boundingbox_range(item)
    range = 32
    {
      bl: RQuad::Vector.new([item.vector.x - range, 0].max, [item.vector.y + range, @height].min),
      tr: RQuad::Vector.new([item.vector.x + range, @width].min, [item.vector.y - range, 0].max)
    }
  end

  def get_candidates (item, tree)
    box = boundingbox_range item
    tree.payloads_in_region(box[:bl], box[:tr]).map(&:data)
  end

  def get_collisions(collidables, tree)
    collidables.each do |item|
      get_candidates(item, tree).each do |tree_item|
        if did_collide? item, tree_item
          yield item, tree_item
        end
      end
    end
  end

  def did_collide?(a, b)
    a.is_live? && b.is_live? && a.radius + b.radius >= a.dist_to(b)
  end

  def notify_collisions
    effects = []
    asteroids = []

    #check shots for astroid colissions
    collideables = @shots.dup
    collideables.push(@ship) if @ship.collides?
    get_collisions(collideables, @asteroids_quad) do |item, asteroid|
      # push effects and split asteroids
      new_effects, new_asteroids = asteroid.hit! item
      effects.concat new_effects
      asteroids.concat new_asteroids

      effects.concat item.hit!(asteroid)
    end

    [effects, asteroids]
  end
end