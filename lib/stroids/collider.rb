require 'rquad'
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

  def get_candidates (item, tree)
    tree.approx_near(item.vector, 5).map(&:data)
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
    #check shots for astroid colissions
    get_collisions(@shots + [@ship], @asteroids_quad) do |item, asteroid|
      asteroid.hit! item
      item.hit! asteroid
    end
  end
end